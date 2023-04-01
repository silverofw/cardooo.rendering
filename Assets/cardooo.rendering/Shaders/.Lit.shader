Shader "DeNA/Lit"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
	}

	HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

	#pragma vertex Vert
	#pragma fragment Frag
	ENDHLSL

	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#include "Lit.hlsl"
			ENDHLSL
		}
	}
}
