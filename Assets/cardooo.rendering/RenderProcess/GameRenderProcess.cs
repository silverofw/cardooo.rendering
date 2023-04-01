using UnityEngine;
using UnityEngine.Rendering;
using static UnityEngine.Experimental.Rendering.RayTracingAccelerationStructure;
using UnityEngine.UI;
using System.Linq;
using System;

namespace cardooo.rendering
{
    [CreateAssetMenu(fileName = "GameProcess", menuName = "Cardooo/Rendering/Game Rendering Process")]    
    public class GameRenderProcess: RenderProcess
    {
        public bool drawSkyBox;

        public string[] m_ShaderPassNames;
        Vector4[] m_RenderParams;

        public override void Render(in ScriptableRenderContext context, in RenderingData renderingData)
        {
            base.Render(context, renderingData);

            Validate();

            int width = renderingData.camera.pixelWidth;
            int height = renderingData.camera.pixelHeight;
            var antiAliasing = 4;//UserConfigDefine.renderQuality == UserConfigDefine.RenderQuality.VeryLow ? 1 : 4;

            var depthRT = RenderTexture.GetTemporary(width, height, 24, RenderTextureFormat.Depth);
            var geomRT = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGBHalf);
            var lightRT = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.RGB111110Float);
            var colorRT = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);
            var msaaRT = RenderTexture.GetTemporary(width, height, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB, antiAliasing);
            //			var shadowRT = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);
            var shadowRT = colorRT;
            var shadowmapRT = (RenderTexture)null;

            const int NumBlurRTs = 5;
            var blurRTs = new RenderTexture[NumBlurRTs + 1];
            for (int i = 0; i < blurRTs.Length; i++)
            {
                int s = Mathf.Min(NumBlurRTs, i + 1);
                blurRTs[i] = RenderTexture.GetTemporary(width >> s, height >> s, 0, RenderTextureFormat.RGB111110Float);
                blurRTs[i].wrapMode = TextureWrapMode.Mirror;
            }


            var cmd = CommandBufferPool.Get(renderingData.camera.name);

            /*
            var sortingSettings = new SortingSettings(renderingData.camera);

            //var drawingSettings = new DrawingSettings(new ShaderTagId("SRPDefaultUnlit"), sortingSettings);
            var drawingSettings = new DrawingSettings();
            drawingSettings.sortingSettings = sortingSettings;
            for (var i = 0; i < m_ShaderPassNames.Length; i++)
            {
                drawingSettings.SetShaderPassName(i, new ShaderTagId(m_ShaderPassNames[i]));
            }

            var filteringSettings = new FilteringSettings(RenderQueueRange.all);

            context.DrawRenderers(renderingData.cullingResults, ref drawingSettings, ref filteringSettings);
            */


            var sortSettings = new SortingSettings(renderingData.camera);
            sortSettings.criteria = SortingCriteria.CommonOpaque;
            var drawSettings = new DrawingSettings(new ShaderTagId("Geometry"), sortSettings);
            var filterSettings = new FilteringSettings(RenderQueueRange.all);


            // geometry
            cmd.name = "geometry";

            cmd.SetRenderTarget(geomRT, depthRT);
            cmd.ClearRenderTarget(true, true, Color.clear);

            SetupCameraParams(cmd, renderingData.camera, true);

            m_RenderParams[0].Set((float)width, (float)height, 1.0f / width, 1.0f / height);
            cmd.SetGlobalVectorArray(Shader.PropertyToID("_RenderParams"), m_RenderParams);

            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            context.DrawRenderers(renderingData.cullingResults, ref drawSettings, ref filterSettings);



            cmd.name = "TEST";
            cmd.Blit(geomRT, BuiltinRenderTextureType.CameraTarget);

            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            CommandBufferPool.Release(cmd);

            if (shadowRT == colorRT)
            {
                shadowRT = null;
            }
            foreach (var rt in new[] { depthRT, geomRT, lightRT, colorRT, msaaRT, shadowRT, shadowmapRT }.Concat(blurRTs))
            {
                if (rt != null)
                {
                    rt.DiscardContents();
                    RenderTexture.ReleaseTemporary(rt);
                }
            }

            if (drawSkyBox)
                context.DrawSkybox(renderingData.camera);

            // system info
            var resolution = new Vector2Int(Screen.width, Screen.height);
            bool flip2D = false;
            flip2D = flip2D || renderingData.camera.isActiveAndEnabled;
            Primitive2D.Render(context, resolution, !flip2D);
            Primitive.resolution = resolution;
        }

        public static void SetupCameraParams(CommandBuffer cmd, Camera camera, bool renderIntoTexture)
        {
            bool flip = true;
            if (camera.cameraType == CameraType.Game && camera.isActiveAndEnabled && SystemInfo.graphicsUVStartsAtTop)
            {
                flip = renderIntoTexture;
            }
            var projMatrix = GL.GetGPUProjectionMatrix(camera.projectionMatrix, flip);
            var viewMatrix = camera.worldToCameraMatrix;
            //[TODO cardooo]
            //if (ShaderConfig.s_CameraRelativeRendering != 0)
            {
                // Zero out the translation component.
                viewMatrix.SetColumn(3, new Vector4(0, 0, 0, 1));
            }
            var viewProjMatrix = projMatrix * viewMatrix;
            var screenWidth = Math.Max(camera.pixelWidth, 1);
            var screenHeight = Math.Max(camera.pixelHeight, 1);
            var screenSize = new Vector4(screenWidth, screenHeight, 1.0f / screenWidth, 1.0f / screenHeight);
            var screenParams = new Vector4(screenSize.x, screenSize.y, 1 + screenSize.z, 1 + screenSize.w);
            var worldSpaceCameraPos = camera.transform.position;

            float n = camera.nearClipPlane;
            float f = camera.farClipPlane;
            // Analyze the projection matrix.
            // p[2][3] = (reverseZ ? 1 : -1) * (depth_0_1 ? 1 : 2) * (f * n) / (f - n)
            float scale = projMatrix[2, 3] / (f * n) * (f - n);
            bool depth_0_1 = Mathf.Abs(scale) < 1.5f;
            bool reverseZ = scale > 0;
            bool flipProj = projMatrix.inverse.MultiplyPoint(new Vector3(0, 1, 0)).y < 0;
            // http://www.humus.name/temp/Linearize%20depth.txt
            var zBufferParams = reverseZ ? new Vector4(-1 + f / n, 1, -1 / f + 1 / n, 1 / f) : new Vector4(1 - f / n, f / n, 1 / f - 1 / n, 1 / n);
            var projectionParams = new Vector4(flipProj ? -1 : 1, n, f, 1.0f / f);

            float orthoHeight = camera.orthographic ? 2 * camera.orthographicSize : 0;
            float orthoWidth = orthoHeight * camera.aspect;
            var unity_OrthoParams = new Vector4(orthoWidth, orthoHeight, 0, camera.orthographic ? 1 : 0);

            var frustum = new Frustum();
            frustum.planes = new Plane[6];
            frustum.corners = new Vector3[8];
            Frustum.Create(frustum, viewProjMatrix, depth_0_1, reverseZ);
            var frustumPlaneEquations = new Vector4[6];
            // Left, right, top, bottom, near, far.
            for (int i = 0; i < 6; i++)
            {
                frustumPlaneEquations[i] = new Vector4(frustum.planes[i].normal.x, frustum.planes[i].normal.y, frustum.planes[i].normal.z, frustum.planes[i].distance);
            }

            cmd.SetGlobalMatrix(ShaderIDs._ViewMatrix, viewMatrix);
            cmd.SetGlobalMatrix(ShaderIDs._InvViewMatrix, viewMatrix.inverse);
            cmd.SetGlobalMatrix(ShaderIDs._ProjMatrix, projMatrix);
            cmd.SetGlobalMatrix(ShaderIDs._InvProjMatrix, projMatrix.inverse);
            cmd.SetGlobalMatrix(ShaderIDs._ViewProjMatrix, viewProjMatrix);
            cmd.SetGlobalMatrix(ShaderIDs._InvViewProjMatrix, viewProjMatrix.inverse);
            //			cmd.SetGlobalMatrix(ShaderIDs._NonJitteredViewProjMatrix, nonJitteredViewProjMatrix);
            //			cmd.SetGlobalMatrix(ShaderIDs._PrevViewProjMatrix, prevViewProjMatrix);
            cmd.SetGlobalVector(ShaderIDs._WorldSpaceCameraPos, worldSpaceCameraPos);
            //			cmd.SetGlobalVector(ShaderIDs._PrevCamPosRWS, (ShaderConfig.s_CameraRelativeRendering != 0) ?
            //				prevWorldSpaceCameraPos - worldSpaceCameraPos : prevWorldSpaceCameraPos);
            cmd.SetGlobalVector(ShaderIDs._ScreenSize, screenSize);
            //			cmd.SetGlobalVector(ShaderIDs._ScreenToTargetScale, doubleBufferedViewportScale);
            //			cmd.SetGlobalVector(ShaderIDs._ZBufferParams, zBufferParams);
            //			cmd.SetGlobalVector(ShaderIDs._ProjectionParams, projectionParams);
            //			cmd.SetGlobalVector(ShaderIDs.unity_OrthoParams, unity_OrthoParams);
            cmd.SetGlobalVector(ShaderIDs._ScreenParams, screenParams);
            //			cmd.SetGlobalVector(ShaderIDs._TaaFrameInfo, new Vector4(taaFrameRotation.x, taaFrameRotation.y, taaFrameIndex, taaEnabled ? 1 : 0));
            cmd.SetGlobalVectorArray(ShaderIDs._FrustumPlanes, frustumPlaneEquations);
        }

        public struct Frustum
        {
            public Plane[] planes;  // Left, right, top, bottom, near, far
            public Vector3[] corners; // Positions of the 8 corners

            // The frustum will be camera-relative if given a camera-relative VP matrix.
            public static void Create(Frustum frustum, Matrix4x4 viewProjMatrix, bool depth_0_1, bool reverseZ)
            {
                GeometryUtility.CalculateFrustumPlanes(viewProjMatrix, frustum.planes);

                float nd = -1.0f;

                if (depth_0_1)
                {
                    nd = 0.0f;

                    // See "Fast Extraction of Viewing Frustum Planes" by Gribb and Hartmann.
                    Vector3 f = new Vector3(viewProjMatrix.m20, viewProjMatrix.m21, viewProjMatrix.m22);
                    float s = (float)(1.0 / Math.Sqrt(f.sqrMagnitude));
                    Plane np = new Plane(s * f, s * viewProjMatrix.m23);

                    frustum.planes[4] = np;
                }

                if (reverseZ)
                {
                    Plane tmp = frustum.planes[4];
                    frustum.planes[4] = frustum.planes[5];
                    frustum.planes[5] = tmp;
                }

                Matrix4x4 invViewProjMatrix = viewProjMatrix.inverse;

                // Unproject 8 frustum points.
                frustum.corners[0] = invViewProjMatrix.MultiplyPoint(new Vector3(-1, -1, 1));
                frustum.corners[1] = invViewProjMatrix.MultiplyPoint(new Vector3(1, -1, 1));
                frustum.corners[2] = invViewProjMatrix.MultiplyPoint(new Vector3(-1, 1, 1));
                frustum.corners[3] = invViewProjMatrix.MultiplyPoint(new Vector3(1, 1, 1));
                frustum.corners[4] = invViewProjMatrix.MultiplyPoint(new Vector3(-1, -1, nd));
                frustum.corners[5] = invViewProjMatrix.MultiplyPoint(new Vector3(1, -1, nd));
                frustum.corners[6] = invViewProjMatrix.MultiplyPoint(new Vector3(-1, 1, nd));
                frustum.corners[7] = invViewProjMatrix.MultiplyPoint(new Vector3(1, 1, nd));
            }
        } // struct Frustum


        public override void ModifyCulling(ref ScriptableCullingParameters parameters)
        {
            base.ModifyCulling(ref parameters);
        }

        void Validate()
        {
            if (m_RenderParams == null || m_RenderParams.Length < 1)
            {
                m_RenderParams = new Vector4[1];
            }
        }
    }
}
