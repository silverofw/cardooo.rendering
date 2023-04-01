Shader "Sharin/Primitive" {
	Properties {
//		_MainTex("Texture", 2D) = "white" {}
//		[Enum(UnityEngine.Rendering.BlendMode)] _SrcFactor("Src Factor", Float) = 1
//		[Enum(UnityEngine.Rendering.BlendMode)] _DstFactor("Dst Factor", Float) = 0
	}

	HLSLINCLUDE
	#include "Common.hlsl"

	TEXTURE2D(_MainTex);
	SAMPLER(sampler_MainTex);

	float4 _MainTex_ST;
	float4 _PrimitiveParams[2];

	#pragma vertex Vert
	#pragma fragment Frag
	ENDHLSL

	SubShader {
		Tags { "RenderType" = "Primitive" }

		Blend [_BlendSrcColor][_BlendDstColor], Zero One

		Pass {
			Tags { "LightMode" = "Primitive2D" }

//			Cull Off
			ZTest Off
			ZWrite On

			HLSLPROGRAM
			#pragma multi_compile _ TEXTURE FONT

			struct Attributes {
				float3 positionOS : POSITION;
				float4 color : COLOR;
			};

			struct Varyings {
				float4 positionCS : SV_POSITION;
#ifndef FONT
				float4 color : COLOR;
#endif
#if defined(TEXTURE) | defined(FONT)
				float2 texcoord : TEXCOORD0;
#endif
			};

			Varyings Vert(Attributes input) {
				Varyings output;

#if 1
				float4x4 m = GetRawUnityObjectToWorld();
#ifdef FONT
				input.positionOS.xy = input.positionOS.xy * _MainTex_ST.xy + _MainTex_ST.zw;
#endif
				output.positionCS = float4(m._m00_m11 * input.positionOS.xy + m._m03_m13, UNITY_NEAR_CLIP_VALUE, 1);
#else
				output.positionCS = mul(GetRawUnityObjectToWorld(), float4(input.positionOS, 1));
#endif
#if defined(FONT)
				output.texcoord = input.color.xy;
#elif defined(TEXTURE)
				output.texcoord = input.color.xy * _PrimitiveParams[1].xy + _PrimitiveParams[1].zw;
				output.color = _PrimitiveParams[0];
#else
				output.color = lerp(_PrimitiveParams[0], _PrimitiveParams[1], input.color.z);
#endif

				return output;
			}

			half4 Frag(Varyings input) : SV_Target0 {
				half4 output;
#if defined(FONT)
				half a = SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, input.texcoord, 0).a;
				output = lerp(_PrimitiveParams[0], _PrimitiveParams[1], a);
				clip(output.a - 0.001h);
#elif defined(TEXTURE)
				output = input.color * SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, input.texcoord, 0);
#else
				output = input.color;
#endif
				return output;
			}
			ENDHLSL
		}

		Pass {
			Tags { "LightMode" = "Primitive3D" }

			ZWrite [_ZWrite]

			HLSLPROGRAM
			#pragma multi_compile _ SHADING TEXTURE FONT
			#pragma multi_compile _ BILLBOARD

			struct Attributes {
				float3 positionOS : POSITION;
#ifdef SHADING
				float3 normalOS : NORMAL;
#endif
				float4 color : COLOR;
			};

			struct Varyings {
				float4 positionCS : SV_POSITION;
#ifdef SHADING
				float3 positionRWS : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
#endif
#ifndef FONT
				float4 color : COLOR;
#endif
#if defined(TEXTURE) | defined(FONT)
				float2 texcoord : TEXCOORD0;
#endif
			};

			Varyings Vert(Attributes input) {
				Varyings output;

#if defined(FONT)
				float4x4 m = GetObjectToWorldMatrix();
				float3 positionRWS = m._m03_m13_m23;
				output.positionCS = TransformWorldToHClip(positionRWS);
				float2 v = 2 * _ScreenSize.zw * output.positionCS.w;
				v.y *= _ProjectionParams.x;
				output.positionCS.xy += v * m._m00_m11 * (input.positionOS.xy * _MainTex_ST.xy + _MainTex_ST.zw);
#elif defined(BILLBOARD)
				float4x4 m = GetObjectToWorldMatrix();
				float3 positionRWS = m._m03_m13_m23;
				float3 positionVS = TransformWorldToView(positionRWS);
				positionVS += m._m00_m11_m20 * input.positionOS;
				output.positionCS = TransformWViewToHClip(positionVS);
#else
				float3 positionRWS = TransformObjectToWorld(input.positionOS);
				output.positionCS = TransformWorldToHClip(positionRWS);
#endif
#ifdef SHADING
				output.positionRWS = positionRWS;
				output.normalWS = TransformObjectToWorldNormal(input.normalOS);
#endif
#if defined(FONT)
				output.texcoord = input.color.xy;
#elif defined(TEXTURE)
				output.texcoord = input.color.xy * _PrimitiveParams[1].xy + _PrimitiveParams[1].zw;
				output.color = _PrimitiveParams[0];
#elif defined(SHADING)
				output.color = _PrimitiveParams[0];
#else
				output.color = lerp(_PrimitiveParams[0], _PrimitiveParams[1], input.color.z);
#endif

				return output;
			}

			half4 Frag(Varyings input) : SV_Target0 {
				half4 output;
#if defined(FONT)
				half a = SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, input.texcoord, 0).a;
				output = lerp(_PrimitiveParams[0], _PrimitiveParams[1], a);
				clip(output.a - 0.001h);
#elif defined(TEXTURE)
				output = input.color * SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, input.texcoord, 0);
#elif defined(SHADING)
				output = input.color;
				half3 n = normalize(input.normalWS);
				half3 v = GetWorldSpaceNormalizeViewDir(input.positionRWS);
				//output.rgb = output.rgb * output.rgb;
				output.rgb *= 0.5h + 0.5h * dot(n, v);
				//output.rgb = sqrt(output.rgb);
#else
				output = input.color;
#endif
				return output;
			}
			ENDHLSL
		}
	}
}
