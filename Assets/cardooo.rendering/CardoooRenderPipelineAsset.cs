using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace cardooo.rendering
{ 
    [CreateAssetMenu(menuName = "Cardooo/Rendering/CardoooRender Pipeline Asset")]
    public class CardoooRenderPipelineAsset : RenderPipelineAsset
    {
        protected override RenderPipeline CreatePipeline()
        {
            return new CardoooRenderPipeline();
        }
    }
}
