using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace cardooo.rendering
{
    public class Primitive
    {
        public enum FillMode
        {
            Wireframe = 1 << 0,
            Solid = 1 << 1,
            SolidWireframe = Wireframe | Solid,
        }

        public enum PrintType
        {
            Info,
            Warning,
            Error,
        }

        class PrintData
        {
            public string text;
            public PrintType type;
            public float time;
        }

        internal class Batch
        {
            public Matrix4x4 matrix = Matrix4x4.identity;
            public Mesh mesh = null;
            public Material material0 = null;
            public Material material1 = null;
            public int submesh = -1;
            public bool managed = false;
        }

        const float c_TextScale = 1000;

        static bool s_Enabled;
        static Vector2Int s_Resolution;
        static float s_TextScale;
        static Stack<Material> s_Materials;
        static List<string> s_Texts;
        static List<PrintData> s_Prints;
        static Texture2D s_FontTexture;
        static Mesh s_TextMesh0;
        static Mesh s_TextMesh;
        static Mesh s_PointMesh;
        static Mesh s_LineMesh;
        static Mesh s_GridMesh;
        static Mesh s_RectMesh;
        static Mesh s_ArrowMesh;
        static Mesh s_CubeMesh;
        static Mesh s_SphereMesh;
        static Mesh s_CapsuleMesh;
        static Mesh s_CylinderMesh;
        static Mesh s_ConeMesh;
        static Mesh s_FrustumMesh;

        static Primitive()
        {
            s_Enabled = UnityEngine.Debug.isDebugBuild;
            s_Materials = new Stack<Material>();
            s_Texts = new List<string>();
            s_Prints = new List<PrintData>();
        }

        public static bool enabled
        {
            get { return s_Enabled; }
            set { s_Enabled = value; }
        }

        public static float textScale
        {
            get { return s_TextScale; }
        }

        public static Vector2Int resolution
        {
            get { return s_Resolution; }
            set
            {
                s_Resolution = value;
                s_TextScale = Mathf.Max(1, Mathf.Min(s_Resolution.x, s_Resolution.y) >> 9);
            }
        }

        internal static Texture2D fontTexture
        {
            get
            {
				if (s_FontTexture == null) {
					s_FontTexture = new Texture2D(128, 96, TextureFormat.Alpha8, false);
					s_FontTexture.filterMode = FilterMode.Point;
					var c = new Color32[s_FontTexture.width * s_FontTexture.height];
					for (int y = 0; y < s_FontTexture.height; y++) {
						for (int x = 0; x < s_FontTexture.width; x++) {
							c[x + s_FontTexture.width * y] = DebugFont.s_Data[x + 128 * y] > 0 ? new Color32(0, 0, 0, 0) : new Color32(255, 255, 255, 255);
						}
					}
					s_FontTexture.SetPixels32(c);
					s_FontTexture.Apply();
					//System.IO.File.WriteAllBytes("D:/DebugFont.png", s_FontTexture.EncodeToPNG());
				}
                return s_FontTexture;
            }
        }

        internal static Mesh textMesh
        {
            get
            {
				if (s_TextMesh == null) {
					var mesh = s_TextMesh = new Mesh();
					mesh.name = "Primitive Text";
					mesh.MarkDynamic();
				}
                return s_TextMesh;
            }
        }

        static Material AllocMaterial()
        {
            Material material = null;
            while (s_Materials.Count > 0)
            {
                material = s_Materials.Pop();
                if (material != null)
                {
                    break;
                }
            }
            if (material == null)
            {
                material = new Material(Shader.Find("Cardooo/Primitive"));
                //material = new Material(((RenderKernelAsset)GraphicsSettings.renderPipelineAsset).pipelineMaterials[0]);                
            }
            return material;
        }

        internal static Material AllocTextMaterial(in Vector2 offset, in Color textColor, in Color bgColor)
        {
            var material = AllocMaterial();

            material.EnableKeyword("FONT");
            material.mainTexture = fontTexture;
            material.mainTextureScale = c_TextScale * Vector2.one;
            material.mainTextureOffset = new Vector2(offset.x, -17.0f / 16.0f * offset.y);

            var v = new[] { (Vector4)textColor, (Vector4)bgColor, };
            material.SetVectorArray(ShaderIDs._PrimitiveParams, v);

            bool transparent = (0 < textColor.a && textColor.a < 1) || (0 < bgColor.a && bgColor.a < 1);
            SetRenderState(material, transparent);

            return material;
        }

        static void SetRenderState(Material material, bool transparent)
        {
            material.SetInt(ShaderIDs.ZWriteID, transparent ? 0 : 1);
            material.SetInt(ShaderIDs.BlendSrcColorID, (int)(transparent ? BlendMode.SrcAlpha : BlendMode.One));
            material.SetInt(ShaderIDs.BlendDstColorID, (int)(transparent ? BlendMode.OneMinusSrcAlpha : BlendMode.Zero));
            material.renderQueue = (int)(transparent ? RenderQueue.Transparent : RenderQueue.Geometry);
        }

        internal static void ReleaseMaterial(Material material)
        {
            material.mainTexture = null;
            material.shaderKeywords = null;
            s_Materials.Push(material);
        }

        internal static Matrix4x4 GetTextMatrix(in Vector3 pos, float scale)
        {
            return Matrix4x4.TRS(pos, Quaternion.identity, new Vector3(8 * scale, 16 * scale, 1));
        }

        internal static int RegisterText(string text)
        {
            s_Texts.Add(text);
            return s_Texts.Count - 1;
        }

        internal static void Swap<T>(ref T t0, ref T t1)
        {
            var t = t0;
            t0 = t1;
            t1 = t;
        }

        internal static void Swap()
        {
            if (!enabled)
            {
                return;
            }

            DrawInfo();
            //DrawSheetNumber();
            //DrawPrint();

            CommitText();
            Swap(ref s_TextMesh0, ref s_TextMesh);
            textMesh.subMeshCount = 0;

            Primitive2D.Swap();
            //Primitive3D.Swap();
        }

        static void CommitText()
        {
            const float f = 1.0f / c_TextScale;
            const float w = 1.0f / 16.0f;
            const float h = 1.0f / 6.0f;
            const float l = 17.0f / 16.0f;
            var vertices = new List<Vector3>();
            var colors = new List<Color>();
            var counts = new List<int>();
            foreach (var text in s_Texts)
            {
                if (string.IsNullOrEmpty(text))
                {
                    vertices.Add(f * new Vector3(0, -1));
                    vertices.Add(f * new Vector3(0, -0));
                    vertices.Add(f * new Vector3(1, -0));
                    vertices.Add(f * new Vector3(1, -1));
                    colors.Add(new Color(w * 15, h * 6, 0, 0));
                    colors.Add(new Color(w * 15, h * 5, 0, 0));
                    colors.Add(new Color(w * 16, h * 5, 0, 0));
                    colors.Add(new Color(w * 16, h * 6, 0, 0));
                    counts.Add(4);
                    continue;
                }

                int n = 0;
                int i = 0;
                int j = 0;
                foreach (var c in text)
                {
                    if (c == '\n')
                    {
                        i = 0;
                        j--;
                    }
                    else if (c == '\t')
                    {
                        var t = 4 - i % 4;
                        vertices.Add(f * new Vector3(i + 0, l * j - 1));
                        vertices.Add(f * new Vector3(i + 0, l * j - 0));
                        vertices.Add(f * new Vector3(i + t, l * j - 0));
                        vertices.Add(f * new Vector3(i + t, l * j - 1));
                        colors.Add(new Color(w * 0, h * 1, 0, 0));
                        colors.Add(new Color(w * 0, h * 0, 0, 0));
                        colors.Add(new Color(w * 1, h * 0, 0, 0));
                        colors.Add(new Color(w * 1, h * 1, 0, 0));
                        n += 4;
                        i += t;
                    }
                    else if (0x20 <= c && c < 0x7F)
                    {
                        var x0 = c % 16;
                        var y0 = c / 16 - 0x20;
                        var x1 = x0 + 1;
                        var y1 = y0 + 1;
                        vertices.Add(f * new Vector3(i + 0, l * j - 1));
                        vertices.Add(f * new Vector3(i + 0, l * j - 0));
                        vertices.Add(f * new Vector3(i + 1, l * j - 0));
                        vertices.Add(f * new Vector3(i + 1, l * j - 1));
                        colors.Add(new Color(w * x0, h * y1, 0, 0));
                        colors.Add(new Color(w * x0, h * y0, 0, 0));
                        colors.Add(new Color(w * x1, h * y0, 0, 0));
                        colors.Add(new Color(w * x1, h * y1, 0, 0));
                        n += 4;
                        i++;
                    }
                    else
                    {
                        i++;
                    }
                }
                counts.Add(n);
            }
            textMesh.vertices = vertices.ToArray();
            textMesh.colors = colors.ToArray();

            textMesh.subMeshCount = counts.Count;
            var indices = new List<int>();
            int i0 = 0;
            int s = 0;
            foreach (var n in counts)
            {
                int i = i0;
                i0 += n;
                indices.Clear();
                for (; i < i0; i++)
                {
                    indices.Add(i);
                }
                textMesh.SetIndices(indices.ToArray(), MeshTopology.Quads, s++);
            }
            textMesh.UploadMeshData(false);

            s_Texts.Clear();
        }

        static void DrawInfo()
        {
            string str = string.Format("-- Cardooo Rendering Ver.{0:F2} --", 0.01f) + System.Environment.NewLine;
            str += SystemInfo.operatingSystem + System.Environment.NewLine;
            str += string.Format("{0} {1}", SystemInfo.deviceModel, SystemInfo.deviceName, SystemInfo.deviceType) + System.Environment.NewLine;
            str += string.Format("{0}  {1}Core {2:F1}GHz RAM {3:F0}GB", SystemInfo.processorType, SystemInfo.processorCount, 0.001f * SystemInfo.processorFrequency, SystemInfo.systemMemorySize / 1024.0f) + System.Environment.NewLine;
            str += string.Format("{1}  {2}  ShaderLevel {4} VRAM {5:F0}GB", SystemInfo.graphicsDeviceVendor, SystemInfo.graphicsDeviceName, SystemInfo.graphicsDeviceType, SystemInfo.graphicsDeviceVersion, SystemInfo.graphicsShaderLevel, SystemInfo.graphicsMemorySize / 1024.0f) + System.Environment.NewLine;
            str += string.Format(SystemInfo.graphicsDeviceVersion) + System.Environment.NewLine;
            str += string.Format("Screen {0} {1} ", resolution.x, resolution.y) + (SystemInfo.graphicsUVStartsAtTop ? " UVStartsAtTop" : "") + (SystemInfo.usesReversedZBuffer ? " ReversedZBuffer" : "") + System.Environment.NewLine;
            {
                float gpuTime = float.NaN;//RenderTiming.instance != null ? RenderTiming.instance.deltaTime : float.NaN;
                var currentProcess = System.Diagnostics.Process.GetCurrentProcess();
                currentProcess.Refresh();
                str += string.Format("Frame {0}", Time.frameCount) + string.Format(" FPS {0:F0}", Mathf.Round(1 / Time.deltaTime)) + string.Format(" (CPU {0:F1}ms/GPU {1:F1}ms)", 1000 * Time.deltaTime, 1000 * gpuTime) + string.Format(" MEM {0}MB", currentProcess.WorkingSet64 >> 20) + System.Environment.NewLine;
                //str += string.Format("Frame {0}", Time.frameCount) + string.Format(" FPS {0:F0}", Mathf.Round(1 / Time.deltaTime)) + System.Environment.NewLine;
            }
            str += "-- CAMERA --" + System.Environment.NewLine;
            str += Camera.main.worldToCameraMatrix.GetRow(0) + System.Environment.NewLine;
            str += Camera.main.worldToCameraMatrix.GetRow(1) + System.Environment.NewLine;
            str += Camera.main.worldToCameraMatrix.GetRow(2) + System.Environment.NewLine;
            str += Camera.main.worldToCameraMatrix.GetRow(3) + System.Environment.NewLine;
            //str += string.Format("{0} {1} {2} {3} {4}", Time.fixedTime, Time.realtimeSinceStartup, Time.time, Time.timeSinceLevelLoad, Time.unscaledTime) + System.Environment.NewLine;
#if false
			str += " !\"#$%&'()*+,-./" + System.Environment.NewLine;
			str += "0123456789:;<=>?" + System.Environment.NewLine;
			str += "@ABCDEFGHIJKLMNO" + System.Environment.NewLine;
			str += "PQRSTUVWXYZ[\\]^_" + System.Environment.NewLine;
			str += "`abcdefghijklmno" + System.Environment.NewLine;
			str += "pqrstuvwxyz{|}~" + System.Environment.NewLine;
#endif
            Primitive2D.DrawText(0, str, Vector2.up, new Vector2(2, 1), textScale);
        }
    }
}
