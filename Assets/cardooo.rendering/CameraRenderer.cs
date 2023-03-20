using UnityEngine;
using UnityEngine.Rendering;
namespace cardooo.rendering
{
    public class CameraRenderer
    {
        ScriptableRenderContext context;
        Camera camera;

        const string bufferName = "Cardooo Render Camera";

        CommandBuffer buffer = new CommandBuffer { name = bufferName };

        CullingResults cullingResults;

        static ShaderTagId unlitShderTagId = new ShaderTagId("SRPDefaultUnlit");

        /// <summary>
        /// �B�׭簣
        /// </summary>
        /// <returns></returns>
        bool Cull()
        {
            if (camera.TryGetCullingParameters(out ScriptableCullingParameters p))
            {
                cullingResults = context.Cull(ref p);
                return true;
            }
            return false;
        }

        public void Render(ScriptableRenderContext context, Camera camera)
        {
            this.context = context;
            this.camera = camera;

            if (!Cull())
            {
                return;
            }

            Setup();
            DrawVisibleGeometry();
            Submit();
        }

        void Setup()
        {
            context.SetupCameraProperties(camera);
            buffer.BeginSample(bufferName);
            // �M���ª����e
            buffer.ClearRenderTarget(true, true, Color.clear);
            ExcuteBuffer();
        }

        void Submit()
        {
            buffer.EndSample(bufferName);
            ExcuteBuffer();
            context.Submit();
        }

        void ExcuteBuffer()
        {
            context.ExecuteCommandBuffer(buffer);
            buffer.Clear();
        }

        void DrawVisibleGeometry()
        {
            var sortingSettings = new SortingSettings(camera);
            var drawingSettings = new DrawingSettings(unlitShderTagId, sortingSettings);
            var filteringSettings = new FilteringSettings(RenderQueueRange.all);

            context.DrawRenderers(cullingResults, ref drawingSettings, ref filteringSettings);

            // draw skybox
            context.DrawSkybox(camera);
        }
    }
}