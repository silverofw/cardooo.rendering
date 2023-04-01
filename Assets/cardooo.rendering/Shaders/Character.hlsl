#if defined(_EDIT_ON) && !defined(_REFLECTIONTEX_ON)
#define _REFLECTIONTEX_ON
#endif

float4 _CharacterParams[10];
float4 _EyeParams[6];
float4 _AvatarParams[6];
float4 _CutoffParams[2];

TEXTURE3D(_AvatarTex0);
SAMPLER(sampler_AvatarTex0);
TEXTURE2D(_CutoffTex);
SAMPLER(sampler_CutoffTex);

static const half ShadowPlane = _CharacterParams[0].y;
static const half3 ShadowScale = half3(_CharacterParams[0].xz, 1).xzy;
static const half ShadowAlpha = _CharacterParams[0].w;
static const half3 SceneMultiplier = _CharacterParams[1].xyz;
static const half GlobalEmissive = _CharacterParams[1].w;
static const half3 LightDir = _CharacterParams[2].xyz;
static const half3 LightColor = _CharacterParams[3].xyz;
static const half3 ShadowColor = _CharacterParams[4].xyz;
static const half3 ReflectionColor = _CharacterParams[5].xyz;
static const half3 ExtraLightColor = _CharacterParams[6].xyz;
static const half3 ExtraShadowColor = _CharacterParams[7].xyz;
static const half Alpha = _CharacterParams[8].w;
static const half3 BiasPos = _CharacterParams[8].xyz - _WorldSpaceCameraPos;
static const half3 GlobalBendBiasPos = BiasPos + GlobalBendOffset(BiasPos);
static const half2 BiasParams = _CharacterParams[9].xy;
static const half2 EyeGrid = max(1.0h, round(half2(_EyeGrid)));
static const half2 RecipEyeGrid = rcp(EyeGrid);
//static const half2 EyeScrollScale = max(0.0h, _EyeScrollScale);
static const half4 EyeBlend[4] = {
	half4(_EyeBlend0.x, _EyeBlend1.x, _EyeBlend2.x, _EyeBlend3.x),
	half4(_EyeBlend4.x, _EyeBlend5.x, _EyeBlend6.x, _EyeBlend7.x),
	half4(_EyeBlend0.y, _EyeBlend1.y, _EyeBlend2.y, _EyeBlend3.y),
	half4(_EyeBlend4.y, _EyeBlend5.y, _EyeBlend6.y, _EyeBlend7.y),
};
static const half3 EyeOffset[2] = {
	half3(0.1h * (_EyeOffset + half2(dot(EyeBlend[0], _EyeParams[0]), dot(EyeBlend[2], _EyeParams[0])) + half2(dot(EyeBlend[1], _EyeParams[1]), dot(EyeBlend[3], _EyeParams[1]))), _EyeParams[5].x),
	half3(0.1h * (_EyeOffset + half2(dot(EyeBlend[0], _EyeParams[2]), dot(EyeBlend[2], _EyeParams[2])) + half2(dot(EyeBlend[1], _EyeParams[3]), dot(EyeBlend[3], _EyeParams[3]))), 1 - _EyeParams[5].y),
};
static const half2 EyeIndex[2] = {
	_EyeParams[4].xy,
	_EyeParams[4].zw,
};
static const half4 OutlineParam = max(0, half4(0.001, 0.001, 1, 1) * _OutlineParam);
static const half3 OutlineColor = SceneMultiplier * _OutlineColor.rgb;

float4 TransformWorldToBiasedHClip(float4 positionCS, float3 positionRWS) {
#ifdef _DEPTHBIAS_ON
	positionRWS = BiasParams.x * positionRWS + BiasParams.y * GlobalBendBiasPos;
#endif
	float4 p = TransformWorldToHClip(positionRWS);
	positionCS.z = p.z * positionCS.w / p.w;
	return positionCS;
}

float4 TransformWorldToBiasedHClip(float3 positionRWS) {
	float4 positionCS = TransformWorldToHClip(positionRWS);
#ifdef _DEPTHBIAS_ON
	positionCS = TransformWorldToBiasedHClip(positionCS, positionRWS);
#endif
	return positionCS;
}

half Cutoff(float2 pixelPos) {
	half2 uv = max(_RenderSize.z, _RenderSize.w) * pixelPos * _CutoffParams[0].z + _CutoffParams[0].xy * _Time.y;
	return SAMPLE_TEXTURE2D(_CutoffTex, sampler_CutoffTex, uv).r;
}

half AlphaClip(float2 pixelPos) {
	half a = 1;
#ifdef _ALPHACLIP_ON
#ifdef _CUTOFF_ON
	a = Alpha + Cutoff(pixelPos) - 1.001h;
	clip(a);
#else
	DitherClip(pixelPos, Alpha);
#endif
#endif
	return a;
}

struct Vertex0 {
	float3 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float4 color : COLOR;
};

struct Interpolator0 {
	float4 positionCS : SV_POSITION;
	float3 positionRWS : TEXCOORD0;
};

Interpolator0 CommonVert(Vertex0 input, bool bXY, bool bZ) {
	Interpolator0 output;

	float3 positionRWS = output.positionRWS = TransformObjectToWorld(input.positionOS);
#if defined(_GLOBALBEND_POSITION)
	positionRWS += GlobalBendOffset();
#elif defined(_GLOBALBEND_SHAPE)
	positionRWS += GlobalBendOffset(output.positionRWS);
#endif
	output.positionCS = TransformWorldToHClip(positionRWS);

	input.color.r = 1 - input.color.r;
	half4 v = OutlineParam;
	v.xyw *= input.color.rrg;
	v.xyw *= float3(output.positionCS.w, 1 - smoothstep(0, v.z, length(positionRWS)), 1);

	float3 normalWS = TransformObjectToWorldDir(input.normalOS);
	float3 normalVS = TransformWorldToViewDir(normalWS);
	float2 normalCS = mul((float2x2)GetViewToHClipMatrix(), normalVS.xy);

	if (bXY) {
		output.positionCS.xy += (half)(bZ ? 1 : _OutlineOcclusionValue) * (v.x + v.y) * normalCS;
	}
	if (bZ) {
		positionRWS += v.w * normalize(positionRWS);
		output.positionCS = TransformWorldToBiasedHClip(output.positionCS, positionRWS);
	}

	return output;
}

Interpolator0 GeomVert(Vertex0 input) {
#if defined(_OUTLINEOCCLUSION_ON)
	return CommonVert(input, true, false);
#else
	return CommonVert(input, false, false);
#endif
}

Interpolator0 ShadowVert(Vertex0 input) {
	Interpolator0 output;

	float3 positionRWS = output.positionRWS = TransformObjectToWorld(input.positionOS);
	output.positionRWS.y += _WorldSpaceCameraPos.y - ShadowPlane;
	positionRWS -= ShadowScale * output.positionRWS.y;
	output.positionCS = TransformWorldToHClip(positionRWS + GlobalBendOffset(positionRWS));

	return output;
}

Interpolator0 OutlineVert(Vertex0 input) {
	return CommonVert(input, true, true);
}

half4 GeomFrag(Interpolator0 input) : SV_Target{
	AlphaClip(input.positionCS.xy);

	return half4(input.positionRWS, 1);
}

half4 ShadowFrag(Interpolator0 input) : SV_Target{
	half a = ShadowAlpha;
#ifdef _CUTOFF_ON
	a += Cutoff(input.positionCS.xy);
	a = step(1.001h, a);
#endif
	return half4(0, 0, 0, a * step(0, input.positionRWS.y));
}

half4 OutlineFrag(Interpolator0 input) : SV_Target{
	AlphaClip(input.positionCS.xy);

	half4 output = half4(OutlineColor, 1);
	output = ApplyFog(output, input.positionRWS);
	return output;
}

struct Vertex {
	float3 positionOS : POSITION;
	float3 normalOS : NORMAL;
	float2 uv0 : TEXCOORD0;
#ifdef _TYPE_EYE
	float4 color : COLOR;
#endif
#if defined(_REFLECTION_ON) && defined(_REFLECTIONTEX_ON) && defined(_REFLECTIONUV_TANGENTSPACE)
	float2 uv1 : TEXCOORD1;
#endif
};

struct Interpolator {
	float4 positionCS : SV_POSITION;
	float3 positionRWS : TEXCOORD0;
	float4 normalWS : TEXCOORD1;
	float4 uv : TEXCOORD2;
};

Interpolator CommonVert(Vertex input, bool bReflection) {
	Interpolator output;

	float3 positionRWS = output.positionRWS = TransformObjectToWorld(input.positionOS);
#if defined(_GLOBALBEND_POSITION)
	positionRWS += GlobalBendOffset();
#elif defined(_GLOBALBEND_SHAPE)
	positionRWS += GlobalBendOffset(output.positionRWS);
#endif
	if (bReflection) {
		positionRWS.y = -positionRWS.y - 2 * _WorldSpaceCameraPos.y;
	}
	output.positionCS = TransformWorldToBiasedHClip(positionRWS);
	output.normalWS.xyz = TransformObjectToWorldDir(input.normalOS);
	output.normalWS.w = 0;

	output.uv = input.uv0.xyxy;
#ifdef _TYPE_EYE
#if 0
	input.color.b = 0;
#elif 0
	input.color.b = 1;
	output.uv.x = 1 - output.uv.x;
#endif
	half reversed = step(0.5h, input.color.b);
	half3 offset = lerp(EyeOffset[0], EyeOffset[1], reversed);
	half2 uv = output.uv.xy;
	uv *= EyeGrid;
	uv += offset.xy;
	uv.x += offset.z * (1.0h - 2.0h * uv.x);
	output.uv.xy = uv;
	output.normalWS.w = reversed;
#endif

#if defined(_REFLECTION_ON) && defined(_REFLECTIONTEX_ON)
#if defined(_REFLECTIONUV_VIEWSPACE)
	half3 a = normalize(-positionRWS);
	half3 b = GetWorldToViewMatrix()._m20_m21_m22;
	half3 c = cross(a, b);
	half d = 1 / (1 + dot(a, b));
	half3x3 m0 = {
		1, 0, 0,
		0, 1, 0,
		0, 0, 1,
	};
	half3x3 m1 = {
		0, -c.z, c.y,
		c.z, 0, -c.x,
		-c.y, c.x, 0,
	};
	half3x3 m = m0 + m1 + m1 * m1 * d;
	half3 n = mul(m, output.normalWS);
	half3 v = TransformWorldToViewDir(n);
	output.uv.zw = v.xy = 0.5h * v.xy + 0.5h;
#elif defined(_REFLECTIONUV_TANGENTSPACE)
	half3 v = mul((half3x3)UNITY_MATRIX_I_M, mul((half3x3)UNITY_MATRIX_I_V, _ReflectionParam2));
	output.uv.zw = input.uv1;
	output.uv.z += dot(_ReflectionParam0, v);
	output.uv.w += dot(_ReflectionParam1, v);
	v = half3(input.uv1, 0);
#endif
#endif

	return output;
}

Interpolator Vert(Vertex input) {
	return CommonVert(input, false);
}

Interpolator ReflVert(Vertex input) {
	return CommonVert(input, true);
}

half4 CommonFrag(Interpolator input, bool bAlpha) {
	half a = AlphaClip(input.positionCS.xy);

#ifdef _TYPE_EYE
	int reversed = step(0.5h, input.normalWS.w);
	input.uv.xy = RecipEyeGrid * (EyeIndex[reversed] + clamp(input.uv.xy, 0.0h, 1.0h));
#endif

	half3 t0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy).rgb;
	half3 t1 = SAMPLE_TEXTURE2D(_SubTex0, sampler_SubTex0, input.uv.xy).rgb;
	half4 t2 = SAMPLE_TEXTURE2D(_SubTex1, sampler_SubTex1, input.uv.xy);
#ifdef _EDIT_ON
	t0 = SAMPLE_TEXTURE2D(_Tex_c, sampler_Tex_c, input.uv.xy).rgb;
	t1 = SAMPLE_TEXTURE2D(_Tex_s, sampler_Tex_s, input.uv.xy).rgb;
	t2.r = bAlpha ?
		SAMPLE_TEXTURE2D(_Tex_alp, sampler_Tex_alp, input.uv.xy).r :
		SAMPLE_TEXTURE2D(_Tex_em, sampler_Tex_em, input.uv.xy).r;
	t2.g = SAMPLE_TEXTURE2D(_Tex_tm, sampler_Tex_tm, input.uv.xy).r;
	t2.b = SAMPLE_TEXTURE2D(_Tex_fm, sampler_Tex_fm, input.uv.xy).r;
	t2.a = SAMPLE_TEXTURE2D(_Tex_sm, sampler_Tex_sm, input.uv.xy).r;
	// TextureConverter reverses it
	t2.gb = 1.0h - t2.gb;
#endif
#ifdef _AVATAR_ON
	half2 t3 = SAMPLE_TEXTURE2D(_SubTex2, sampler_SubTex2, input.uv.xy).rg;
#ifdef _EDIT_ON
	half4 ta;
	ta.x = SAMPLE_TEXTURE2D(_Tex_am, sampler_Tex_am, input.uv.xy).r;
	ta.y = SAMPLE_TEXTURE2D(_Tex_as, sampler_Tex_as, input.uv.xy).r;
	ta.z = SAMPLE_TEXTURE2D(_Tex_ask, sampler_Tex_ask, input.uv.xy).r;
	ta.w = min(1.0h, ta.x + ta.y + ta.z);
	ta.xyz -= min(min(ta.x, ta.y), ta.z);
	ta.xyz /= max(0.001h, ta.x + ta.y + ta.z);
	t3.xy = lerp(1.0h / 3.0h, ta.xy, ta.w);
#endif
#endif
#if defined(_REFLECTION_ON) && defined(_REFLECTIONTEX_ON)
	half2 t4 = input.uv.zw;
#if defined(_REFLECTIONNOISE_POLAR)
	t4 -= 0.5h;
	t4 = half2(-atan2(t4.y, t4.x) / (half)PI, length(t4));
	half2 noise0 = t4;
	half2 noise1 = noise0 - _ReflectionNoiseVelocity * _Time.y;
	noise1 = SAMPLE_TEXTURE2D(_ReflectionNoiseTex, sampler_ReflectionNoiseTex, noise1).rg;
	noise0.x += _ReflectionNoiseScale.x * (0.5h - noise1.x);
	noise0.y *= lerp(1.0h, 2.0h * noise1.y, _ReflectionNoiseScale.y);
	sincos(-(half)PI * noise0.x, noise1.y, noise1.x);
	t4 = noise1 * noise0.y + 0.5h;
#elif defined(_REFLECTIONNOISE_ORTHOGONAL)
	half2 noise = t4;
	noise -= _ReflectionNoiseVelocity * _Time.y;
	t4 += _ReflectionNoiseScale * (0.5h - SAMPLE_TEXTURE2D(_ReflectionNoiseTex, sampler_ReflectionNoiseTex, noise).rg);
#endif
#ifdef _EDIT_ON
	t4 = half2(
		SAMPLE_TEXTURE2D(_Tex_fl, sampler_Tex_fl, t4).r,
		SAMPLE_TEXTURE2D(_Tex_fs, sampler_Tex_fs, t4).r);
#else
	t4 = SAMPLE_TEXTURE2D(_ReflectionTex, sampler_ReflectionTex, t4).rg;
#endif
	t4 *= t2.b;
#endif

	half3 normalWS = normalize(input.normalWS.xyz);
	half3 viewWS = normalize(-input.positionRWS);
	half3 reflectWS = reflect(-viewWS, normalWS);

	half4 v0 = half4(_ToonStep, _SpecularStep, _ToonSmooth, _SpecularSmooth);
	v0 = half4(v0.xy - v0.zw, v0.xy + v0.zw);
	half4 v1;
	v1.x = dot(normalWS, LightDir);
	v1.y = dot(reflectWS, LightDir);
	v1.zw = smoothstep(v0.xy, v0.zw, v1.xy);
	v1.zw *= t2.ga;

	half3 c = lerp(t1, t0, v1.z);
#ifdef _AVATAR_ON
#if 0
#ifdef _AVATARSKIN_ON
	c = lerp(c, lerp(_AvatarParams[5].rgb, _AvatarParams[4].rgb, v1.z), t3.b);
#endif
#ifdef _AVATARSUB_ON
	c = lerp(c, lerp(_AvatarParams[3].rgb, _AvatarParams[2].rgb, v1.z), t3.g);
#endif
#ifdef _AVATARTEX0_ON
	half3 t5 = SAMPLE_TEXTURE2D_LOD(_AvatarTex0, sampler_AvatarTex0, half2(t3.a, v1.z), 0).rgb;
	c = lerp(c, t5, t3.r);
#else
	c = lerp(c, lerp(_AvatarParams[1].rgb, _AvatarParams[0].rgb, v1.z), t3.r);
#endif
	c = lerp(c, _OutlineColor.rgb, al);
#else
	c *= SAMPLE_TEXTURE3D_LOD(_AvatarTex0, sampler_AvatarTex0, _AvatarParams[0].xyz + _AvatarParams[1].xyz * half3(t3.xy, v1.z), 0).rgb;
#endif
#endif

	half3 r = 0;
	half3 o = 1;
#ifdef _SPECULAR_ON
	r += LightColor * _SpecularColor * v1.w;
#endif
#if defined(_REFLECTION_ON) && defined(_REFLECTIONTEX_ON)
#ifndef _REFLECTIONSHADE_ON
	t4 *= v1.z;
#endif
	o = lerp(o, _ReflectionColor1, t4.g);
	r += ReflectionColor * _ReflectionColor0 * t4.r * o;
#endif
	half4 ar = 0;
#if defined(_ALPHACLIP_ON) && defined(_CUTOFF_ON)
	ar.xy = max(half2(0.0h, 0.001h), half2(_CutoffParams[0].w - a, _CutoffParams[0].w));
	ar.x = ar.x / ar.y;
	ar.y = ar.x * ar.x;
	ar = _CutoffParams[1] * ar.y;
	r += ar.rgb;
#endif

	half4 output = half4(c, bAlpha ? t2.r : _Emissive * t2.r + ar.a);
	output.rgb = LightingCharacter(_RenderSize.zw * input.positionCS.xy, output.rgb, LightColor, ShadowColor, o, r);
	output = ApplyFog(output, input.positionRWS);
	output.rgb = ExtraLightColor * v1.z + lerp(ExtraShadowColor, 1, v1.z) * output.rgb;
	return output;
}

half4 Frag(Interpolator input) : SV_Target{
	half4 output = CommonFrag(input, false);
	output = EncodeOpaque(output, GlobalEmissive);
	return output;
}

half4 AlphaFrag(Interpolator input) : SV_Target{
	half4 output = CommonFrag(input, true);
	return output;
}

half4 ReflFrag(Interpolator input) : SV_Target{
	clip(input.positionRWS.y + _WorldSpaceCameraPos.y);

	half4 output = Frag(input);
	return output;
}

half4 ReflAlphaFrag(Interpolator input) : SV_Target{
	clip(input.positionRWS.y + _WorldSpaceCameraPos.y);

	half4 output = AlphaFrag(input);
	return output;
}
