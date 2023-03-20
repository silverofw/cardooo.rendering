using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace cardooo.rendering
{
    public struct RenderingData
    {
        public Camera camera;
        public CullingResults cullingResults;

        public RenderingData(Camera camera, CullingResults cullingResults)
        {
            this.camera = camera;
            this.cullingResults = cullingResults;
        }
    }

    public class RenderProcess : ScriptableObject
    {
        public virtual void ModifyCulling(ref ScriptableCullingParameters parameters) { }
        public virtual void Render(in ScriptableRenderContext context, in RenderingData renderingData) { }
    }
}
