using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace cardooo.rendering
{
    public class CardoooRenderPipeline : RenderPipeline
    {
        RenderProcess defaultProcess = new SceneViewRenderProcess();

        static CullingResults s_CullingResults;

        uint m_FrameCount;
        float m_Time;

        protected override void Render(ScriptableRenderContext context, Camera[] cameras)
        {
            bool newFrame;
            {
                uint c = (uint)Time.frameCount;
                float t = Time.realtimeSinceStartup;
                //Debug.LogFormat("Time: {0} {1}", c, t);

                if (m_FrameCount != c)
                {
                    Primitive.Swap();
                    //Primitive3D.Render(context);
                }

                newFrame = m_FrameCount != c;
                if (!Application.isPlaying)
                {
                    newFrame = (t - m_Time) > 0.0166f;
                }

                m_FrameCount = c;
                m_Time = t;
            }

            // camera renderer
            foreach (var camera in cameras)
            {
                RenderProcess renderProcess = defaultProcess;
                switch (camera.cameraType)
                {
                    case CameraType.Game:
                        var renderCam = camera.GetComponent<RenderCamera>();
                        if (renderCam != null)
                        {
                            renderProcess = renderCam.RenderProcess;
                        }
                        break;
                    default:
                        break;
                }


                // Culling ===============================================================================
                ScriptableCullingParameters cullingParameters;
                if (!camera.TryGetCullingParameters(out cullingParameters))
                {
                    continue;
                }
                renderProcess.ModifyCulling(ref cullingParameters);
                s_CullingResults = context.Cull(ref cullingParameters);


                // Setup ===============================================================================
                //var cmd = CommandBufferPool.Get(camera.name);
                //context.SetupCameraProperties(camera);
                //SetupGlobalParams(cmd, camera);
                // 清除舊的內容
                //cmd.ClearRenderTarget(true, true, Color.clear);

                // Caution: ExecuteCommandBuffer must be outside of the profiling bracket
                //context.ExecuteCommandBuffer(cmd);
                //cmd.Clear();


                // Rendering ===============================================================================
                renderProcess.Render(context, new RenderingData(camera, s_CullingResults));

                // Submit ===============================================================================
                // Caution: ExecuteCommandBuffer must be outside of the profiling bracket
                //context.ExecuteCommandBuffer(cmd);

                //CommandBufferPool.Release(cmd);
                context.Submit();
#if UNITY_EDITOR
                // 畫出攝影機範圍
                Handles.DrawGizmos(camera);
#endif
            }            
        }
    }
}
