using UnityEngine;
using UnityEngine.Rendering;

namespace cardooo.rendering
{
    [CreateAssetMenu(fileName = "GameProcess", menuName = "Cardooo/Rendering/Game Rendering Process")]
    public class SceneViewRenderProcess : RenderProcess
    {
        public override void Render(in ScriptableRenderContext context, in RenderingData renderingData)
        {
            base.Render(context, renderingData);

            var sortingSettings = new SortingSettings(renderingData.camera);
            var drawingSettings = new DrawingSettings(new ShaderTagId("SRPDefaultUnlit"), sortingSettings);
            var filteringSettings = new FilteringSettings(RenderQueueRange.all);

            context.DrawRenderers(renderingData.cullingResults, ref drawingSettings, ref filteringSettings);

            //context.DrawSkybox(renderingData.camera);
        }
        public override void ModifyCulling(ref ScriptableCullingParameters parameters)
        {
            base.ModifyCulling(ref parameters);
        }
    }
}
