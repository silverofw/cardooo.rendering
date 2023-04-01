Shader "Cardooo/Character"
{
	Properties
	{
		[HideInInspector] _Version("Version", Int) = 0
		[NoScaleOffset] _Tex_c("Texture_c", 2D) = "white" {}
		[NoScaleOffset] _Tex_s("Texture_s", 2D) = "white" {}
		[NoScaleOffset] _Tex_alp("Texture_alp", 2D) = "white" {}
		[NoScaleOffset] _Tex_em("Texture_em", 2D) = "white" {}
		[NoScaleOffset] _Tex_tm("Texture_tm", 2D) = "black" {}
		[NoScaleOffset] _Tex_fm("Texture_fm", 2D) = "black" {}
		[NoScaleOffset] _Tex_sm("Texture_sm", 2D) = "white" {}
		[NoScaleOffset] _Tex_am("Texture_am", 2D) = "black" {}
		[NoScaleOffset] _Tex_as("Texture_as", 2D) = "black" {}
		[NoScaleOffset] _Tex_ask("Texture_ask", 2D) = "black" {}
		[NoScaleOffset] _Tex_fl("Texture_fl", 2D) = "black" {}
		[NoScaleOffset] _Tex_fs("Texture_fs", 2D) = "black" {}
		[KeywordEnum(Base, Eye, Alpha)] _Type("Type", Float) = 0
		[KeywordEnum(Position, Shape)] _GlobalBend("Global Bend", Float) = 0
		[Toggle] _Avatar("Avatar", Float) = 0
		[NoScaleOffset] _MainTex("Bright Albedo Texture", 2D) = "white" {}
		[NoScaleOffset] _SubTex0("Dark Albedo Texture", 2D) = "gray" {}
		[NoScaleOffset] _SubTex1("Parameter Texture", 2D) = "white" {}
		[NoScaleOffset] _SubTex2("Avatar Texture", 2D) = "black" {}
		_ToonStep("Toon Border", Range(-1, 1)) = 0
		_ToonSmooth("Toon Smoothing", Range(0, 0.5)) = 0
		[Toggle] _Specular("Specular", Float) = 0
		_SpecularStep("Specular Border", Range(0, 1)) = 1
		_SpecularSmooth("Specular Smoothing", Range(0, 0.5)) = 0
		_SpecularColor("Specular Color", Color) = (1, 1, 1)
		_Emissive("Emissive Intensity", Float) = 0
		[Toggle] _Reflection("Fake Light & Shadow", Float) = 0
		[Toggle] _ReflectionShade("Fake Light & Shadow on Dark", Float) = 1
		[NoScaleOffset] _ReflectionTex("Fake Light Texture", 2D) = "black" {}
		_ReflectionColor0("Fake Light Color", Color) = (1, 1, 1)
		_ReflectionColor1("Fake Shadow Color", Color) = (1, 1, 1)
		[KeywordEnum(View Space, Tangent Space)] _ReflectionUV("Fake Light UV", Float) = 0
		_ReflectionParam0("Fake Light Param X", Vector) = (1, 0, 0)
		_ReflectionParam1("Fake Light Param Y", Vector) = (0, 1, 0)
		_ReflectionParam2("Fake Light Param Z", Vector) = (0, 0, 1)
		[KeywordEnum(None, Orthogonal, Polar)] _ReflectionNoise("Fake Light Noise", Float) = 0
		[NoScaleOffset] _ReflectionNoiseTex("Fake Light Noise Texture", 2D) = "gray" {}
		_ReflectionNoiseScale("Fake Light Noise Scale", Vector) = (0, 0, 0)
		_ReflectionNoiseVelocity("Fake Light Noise Velocity", Vector) = (0, 0, 0)
		_OutlineParam("Outline Param", Vector) = (1, 1, 10, 0)
		_OutlineColor("Outline Color", Color) = (0, 0, 0)
		[Toggle] _OutlineOcclusion("Outline Occluding Transparent", Float) = 1
		_OutlineOcclusionValue("_OutlineOcclusionValue", Range(0, 1)) = 1
		_EyeGrid("Eye Grid", Vector) = (2, 2, 0)
		_EyeOffset("Eye Default Offset", Vector) = (0, 0, 0)
		_EyeBlend0("Eye Blend Offset 0", Vector) = (0, 0, 0)
		_EyeBlend1("Eye Blend Offset 1", Vector) = (0, 0, 0)
		_EyeBlend2("Eye Blend Offset 2", Vector) = (0, 0, 0)
		_EyeBlend3("Eye Blend Offset 3", Vector) = (0, 0, 0)
		_EyeBlend4("Eye Blend Offset 4", Vector) = (0, 0, 0)
		_EyeBlend5("Eye Blend Offset 5", Vector) = (0, 0, 0)
		_EyeBlend6("Eye Blend Offset 6", Vector) = (0, 0, 0)
		_EyeBlend7("Eye Blend Offset 7", Vector) = (0, 0, 0)
	}
	HLSLINCLUDE
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Common.hlsl"

		TEXTURE2D(_Tex_c);
	SAMPLER(sampler_Tex_c);
	float4 _Tex_c_TexelSize;
	TEXTURE2D(_Tex_s);
	SAMPLER(sampler_Tex_s);
	float4 _Tex_s_TexelSize;
	TEXTURE2D(_Tex_alp);
	SAMPLER(sampler_Tex_alp);
	float4 _Tex_alp_TexelSize;
	TEXTURE2D(_Tex_em);
	SAMPLER(sampler_Tex_em);
	float4 _Tex_em_TexelSize;
	TEXTURE2D(_Tex_tm);
	SAMPLER(sampler_Tex_tm);
	float4 _Tex_tm_TexelSize;
	TEXTURE2D(_Tex_fm);
	SAMPLER(sampler_Tex_fm);
	float4 _Tex_fm_TexelSize;
	TEXTURE2D(_Tex_sm);
	SAMPLER(sampler_Tex_sm);
	float4 _Tex_sm_TexelSize;
	TEXTURE2D(_Tex_am);
	SAMPLER(sampler_Tex_am);
	float4 _Tex_am_TexelSize;
	TEXTURE2D(_Tex_as);
	SAMPLER(sampler_Tex_as);
	float4 _Tex_as_TexelSize;
	TEXTURE2D(_Tex_ask);
	SAMPLER(sampler_Tex_ask);
	float4 _Tex_ask_TexelSize;
	TEXTURE2D(_Tex_fl);
	SAMPLER(sampler_Tex_fl);
	float4 _Tex_fl_TexelSize;
	TEXTURE2D(_Tex_fs);
	SAMPLER(sampler_Tex_fs);
	float4 _Tex_fs_TexelSize;
	TEXTURE2D(_MainTex);
	SAMPLER(sampler_MainTex);
	float4 _MainTex_TexelSize;
	TEXTURE2D(_SubTex0);
	SAMPLER(sampler_SubTex0);
	float4 _SubTex0_TexelSize;
	TEXTURE2D(_SubTex1);
	SAMPLER(sampler_SubTex1);
	float4 _SubTex1_TexelSize;
	TEXTURE2D(_SubTex2);
	SAMPLER(sampler_SubTex2);
	float4 _SubTex2_TexelSize;
	float _ToonStep;
	float _ToonSmooth;
	float _SpecularStep;
	float _SpecularSmooth;
	float3 _SpecularColor;
	float _Emissive;
	TEXTURE2D(_ReflectionTex);
	SAMPLER(sampler_ReflectionTex);
	float4 _ReflectionTex_TexelSize;
	float3 _ReflectionColor0;
	float3 _ReflectionColor1;
	float3 _ReflectionParam0;
	float3 _ReflectionParam1;
	float3 _ReflectionParam2;
	TEXTURE2D(_ReflectionNoiseTex);
	SAMPLER(sampler_ReflectionNoiseTex);
	float4 _ReflectionNoiseTex_TexelSize;
	float2 _ReflectionNoiseScale;
	float2 _ReflectionNoiseVelocity;
	float4 _OutlineParam;
	float3 _OutlineColor;
	float _OutlineOcclusionValue;
	float2 _EyeGrid;
	float2 _EyeOffset;
	float2 _EyeBlend0;
	float2 _EyeBlend1;
	float2 _EyeBlend2;
	float2 _EyeBlend3;
	float2 _EyeBlend4;
	float2 _EyeBlend5;
	float2 _EyeBlend6;
	float2 _EyeBlend7;

#pragma shader_feature _TYPE_BASE _TYPE_EYE _TYPE_ALPHA
#pragma shader_feature _GLOBALBEND_POSITION _GLOBALBEND_SHAPE
#pragma shader_feature _AVATAR_ON
#pragma shader_feature _SPECULAR_ON
#pragma shader_feature _REFLECTION_ON
#pragma shader_feature _REFLECTIONSHADE_ON
#pragma shader_feature _REFLECTIONTEX_ON
#pragma shader_feature _REFLECTIONUV_VIEWSPACE _REFLECTIONUV_TANGENTSPACE
#pragma shader_feature _REFLECTIONNOISE_NONE _REFLECTIONNOISE_ORTHOGONAL _REFLECTIONNOISE_POLAR
#pragma shader_feature _OUTLINEOCCLUSION_ON
#pragma multi_compile _ _EDIT_ON
#pragma multi_compile _ _ALPHACLIP_ON
#pragma multi_compile _ _CUTOFF_ON
#pragma multi_compile _ _DEPTHBIAS_ON
	ENDHLSL

	SubShader
	{
		Pass {
			Name "Geometry"
			Tags { "LightMode" = "Geometry" }

			Cull Back
			Offset 0, 0
			ZClip On
			ZTest LEqual
			ZWrite On
			Stencil {
				Ref 0
				ReadMask 127
				WriteMask 127
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

			HLSLPROGRAM
			#pragma vertex GeomVert
			#pragma fragment GeomFrag


			#include "Character.hlsl"
			ENDHLSL
		}
	}
}
