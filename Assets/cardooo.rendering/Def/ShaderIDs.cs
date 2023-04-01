using UnityEngine;

namespace cardooo.rendering
{
    public static class ShaderIDs
    {
        public static readonly int _WorldSpaceCameraPos = Shader.PropertyToID("_WorldSpaceCameraPos");
        public static readonly int _PrevCamPosRWS = Shader.PropertyToID("_PrevCamPosRWS");
        public static readonly int _ViewMatrix = Shader.PropertyToID("_ViewMatrix");
        public static readonly int _InvViewMatrix = Shader.PropertyToID("_InvViewMatrix");
        public static readonly int _ProjMatrix = Shader.PropertyToID("_ProjMatrix");
        public static readonly int _InvProjMatrix = Shader.PropertyToID("_InvProjMatrix");
        public static readonly int _NonJitteredViewProjMatrix = Shader.PropertyToID("_NonJitteredViewProjMatrix");
        public static readonly int _ViewProjMatrix = Shader.PropertyToID("_ViewProjMatrix");
        public static readonly int _InvViewProjMatrix = Shader.PropertyToID("_InvViewProjMatrix");
        public static readonly int _ZBufferParams = Shader.PropertyToID("_ZBufferParams");
        public static readonly int _ProjectionParams = Shader.PropertyToID("_ProjectionParams");
        public static readonly int unity_OrthoParams = Shader.PropertyToID("unity_OrthoParams");
        public static readonly int _InvProjParam = Shader.PropertyToID("_InvProjParam");
        public static readonly int _ScreenSize = Shader.PropertyToID("_ScreenSize");
        public static readonly int _ScreenParams = Shader.PropertyToID("_ScreenParams");
        public static readonly int _ScreenToTargetScale = Shader.PropertyToID("_ScreenToTargetScale");
        public static readonly int _PrevViewProjMatrix = Shader.PropertyToID("_PrevViewProjMatrix");
        public static readonly int _FrustumPlanes = Shader.PropertyToID("_FrustumPlanes");
        public static readonly int _TaaFrameInfo = Shader.PropertyToID("_TaaFrameInfo");

        public static readonly int _MainTex = Shader.PropertyToID("_MainTex");
        public static readonly int _Color = Shader.PropertyToID("_Color");
        public static readonly int _PrimitiveParams = Shader.PropertyToID("_PrimitiveParams");

        public static readonly string ZWriteStr = "_ZWrite";
        public static readonly int ZWriteID = Shader.PropertyToID(ZWriteStr);

        public static readonly string BlendSrcColorStr = "_BlendSrcColor";
        public static readonly int BlendSrcColorID = Shader.PropertyToID(BlendSrcColorStr);

        public static readonly string BlendDstColorStr = "_BlendDstColor";
        public static readonly int BlendDstColorID = Shader.PropertyToID(BlendDstColorStr);
    }
}
