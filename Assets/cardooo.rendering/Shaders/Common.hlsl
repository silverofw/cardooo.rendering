#ifndef DENA_COMMON_HLSL
#define DENA_COMMON_HLSL

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

#if 0
float4x4 InverseMatrix(float4x4 m) {
	float n11 = m[0][0], n12 = m[1][0], n13 = m[2][0], n14 = m[3][0];
	float n21 = m[0][1], n22 = m[1][1], n23 = m[2][1], n24 = m[3][1];
	float n31 = m[0][2], n32 = m[1][2], n33 = m[2][2], n34 = m[3][2];
	float n41 = m[0][3], n42 = m[1][3], n43 = m[2][3], n44 = m[3][3];

	float t11 = n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44;
	float t12 = n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44;
	float t13 = n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44;
	float t14 = n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34;

	float det = n11 * t11 + n21 * t12 + n31 * t13 + n41 * t14;
	float idet = 1.0f / det;

	float4x4 ret;

	ret[0][0] = t11 * idet;
	ret[0][1] = (n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44) * idet;
	ret[0][2] = (n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44) * idet;
	ret[0][3] = (n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43) * idet;

	ret[1][0] = t12 * idet;
	ret[1][1] = (n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44) * idet;
	ret[1][2] = (n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44) * idet;
	ret[1][3] = (n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43) * idet;

	ret[2][0] = t13 * idet;
	ret[2][1] = (n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44) * idet;
	ret[2][2] = (n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44) * idet;
	ret[2][3] = (n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43) * idet;

	ret[3][0] = t14 * idet;
	ret[3][1] = (n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34) * idet;
	ret[3][2] = (n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34) * idet;
	ret[3][3] = (n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33) * idet;

	return ret;
}
#else
float4x4 InverseMatrix(float4x4 input) {
#define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
	//determinant(float3x3(input._22_23_23, input._32_33_34, input._42_43_44))

	float4x4 cofactors = float4x4(
		minor(_22_23_24, _32_33_34, _42_43_44),
		-minor(_21_23_24, _31_33_34, _41_43_44),
		minor(_21_22_24, _31_32_34, _41_42_44),
		-minor(_21_22_23, _31_32_33, _41_42_43),

		-minor(_12_13_14, _32_33_34, _42_43_44),
		minor(_11_13_14, _31_33_34, _41_43_44),
		-minor(_11_12_14, _31_32_34, _41_42_44),
		minor(_11_12_13, _31_32_33, _41_42_43),

		minor(_12_13_14, _22_23_24, _42_43_44),
		-minor(_11_13_14, _21_23_24, _41_43_44),
		minor(_11_12_14, _21_22_24, _41_42_44),
		-minor(_11_12_13, _21_22_23, _41_42_43),

		-minor(_12_13_14, _22_23_24, _32_33_34),
		minor(_11_13_14, _21_23_24, _31_33_34),
		-minor(_11_12_14, _21_22_24, _31_32_34),
		minor(_11_12_13, _21_22_23, _31_32_33)
		);
#undef minor
	return transpose(cofactors) / determinant(input);
}
#endif

float EncodeDepth(float depth) {
#if !UNITY_REVERSED_Z
	const float D = 1 / (UNITY_RAW_FAR_CLIP_VALUE - UNITY_NEAR_CLIP_VALUE);
	depth = D * (depth - UNITY_NEAR_CLIP_VALUE);
#endif
	return depth;
}

float DecodeDepth(float depth) {
#if !UNITY_REVERSED_Z
	const float D = UNITY_RAW_FAR_CLIP_VALUE - UNITY_NEAR_CLIP_VALUE;
	depth = D * depth + UNITY_NEAR_CLIP_VALUE;
#endif
	return depth;
}

inline half3 DecodeHDR(half4 data, half4 decodeInstructions) {
    // Take into account texture alpha if decodeInstructions.w is true(the alpha value affects the RGB channels)
    half alpha = decodeInstructions.w * (data.a - 1.0) + 1.0;

#if 1
	return (decodeInstructions.x * alpha) * data.rgb;
#else
    // If Linear mode is not supported we can skip exponent part
    #if defined(UNITY_COLORSPACE_GAMMA)
        return (decodeInstructions.x * alpha) * data.rgb;
    #else
    #   if defined(UNITY_USE_NATIVE_HDR)
            return decodeInstructions.x * data.rgb; // Multiplier for future HDRI relative to absolute conversion.
    #   else
            return (decodeInstructions.x * pow(alpha, decodeInstructions.y)) * data.rgb;
    #   endif
    #endif
#endif
}

//#line 8 "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
struct FragInput
{
	// Contain value return by SV_POSITION (That is name positionCS in PackedVarying).
	// xy: unormalized screen position (offset by 0.5), z: device depth, w: depth in view space
	// Note: SV_POSITION is the result of the clip space position provide to the vertex shaders that is transform by the viewport
	float4 positionSS; // In case depth offset is use, positionRWS.w is equal to depth offset
	float3 positionRWS; // Relative camera space position
	float4 texCoord0;
	float4 texCoord1;
	float4 texCoord2;
	float4 texCoord3;
	float4 color; // vertex color

	// TODO: confirm with Morten following statement
	// Our TBN is orthogonal but is maybe not orthonormal in order to be compliant with external bakers (Like xnormal that use mikktspace).
	// (xnormal for example take into account the interpolation when baking the normal and normalizing the tangent basis could cause distortion).
	// When using worldToTangent with surface gradient, it doesn't normalize the tangent/bitangent vector (We instead use exact same scale as applied to interpolated vertex normal to avoid breaking compliance).
	// this mean that any usage of worldToTangent[1] or worldToTangent[2] outside of the context of normal map (like for POM) must normalize the TBN (TCHECK if this make any difference ?)
	// When not using surface gradient, each vector of worldToTangent are normalize (TODO: Maybe they should not even in case of no surface gradient ? Ask Morten)
	float3x3 worldToTangent;

	// For two sided lighting
	bool isFrontFace;
};

//#line 6 "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
//#line 10 "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderConfig.cs.hlsl"
#define SHADEROPTIONS_CAMERA_RELATIVE_RENDERING (1)

//#line 62 "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
float4x4 unity_ObjectToWorld;
float4x4 unity_WorldToObject;
float4 unity_LODFade; // x is the fade value ranging within [0,1]. y is x quantized into 16 levels
float4 unity_WorldTransformParams; // w is usually 1.0, or -1.0 for odd-negative scale transforms
float4 unity_RenderingLayer;

float4 unity_LightmapST;
float4 unity_DynamicLightmapST;

// SH lighting environment
float4 unity_SHAr;
float4 unity_SHAg;
float4 unity_SHAb;
float4 unity_SHBr;
float4 unity_SHBg;
float4 unity_SHBb;
float4 unity_SHC;

// x = Disabled(0)/Enabled(1)
// y = Computation are done in global space(0) or local space(1)
// z = Texel size on U texture coordinate
float4 unity_ProbeVolumeParams;
float4x4 unity_ProbeVolumeWorldToObject;
float4 unity_ProbeVolumeSizeInv; // Note: This variable is float4 and not float3 (compare to builtin unity) to be compatible with SRP batcher
float4 unity_ProbeVolumeMin; // Note: This variable is float4 and not float3 (compare to builtin unity) to be compatible with SRP batcher

 // This contain occlusion factor from 0 to 1 for dynamic objects (no SH here)
float4 unity_ProbesOcclusion;

// Velocity
float4x4 unity_MatrixPreviousM;
float4x4 unity_MatrixPreviousMI;
//X : Use last frame positions (right now skinned meshes are the only objects that use this
//Y : Force No Motion
//Z : Z bias value
float4 unity_MotionVectorsParams;

//#line 189 "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
// ================================
//     PER FRAME CONSTANTS
// ================================
float4x4 glstate_matrix_projection;
float4x4 unity_MatrixV;
float4x4 unity_MatrixInvV;
float4x4 unity_MatrixVP;
float4 unity_StereoScaleOffset;
int unity_StereoEyeIndex;

//#line 201 "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
// ================================
//     PER VIEW CONSTANTS
// ================================
// TODO: all affine matrices should be 3x4.
float4x4 _ViewMatrix;
float4x4 _InvViewMatrix;
float4x4 _ProjMatrix;
float4x4 _InvProjMatrix;
float4x4 _ViewProjMatrix;
float4x4 _InvViewProjMatrix;
float4x4 _NonJitteredViewProjMatrix;
float4x4 _PrevViewProjMatrix;       // non-jittered

float4 _TextureWidthScaling; // 0.5 for SinglePassDoubleWide (stereo) and 1.0 otherwise

// TODO: put commonly used vars together (below), and then sort them by the frequency of use (descending).
// Note: a matrix is 4 * 4 * 4 = 64 bytes (1x cache line), so no need to sort those.
#ifndef USING_STEREO_MATRICES
float3 _WorldSpaceCameraPos;
float  _Pad0;
float3 _PrevCamPosRWS;
float  _Pad1;
#endif
float4 _ScreenSize;                 // { w, h, 1 / w, 1 / h }
float4 _ScreenToTargetScale;        // { w / RTHandle.maxWidth, h / RTHandle.maxHeight } : xy = currFrame, zw = prevFrame

// Values used to linearize the Z buffer (http://www.humus.name/temp/Linearize%20depth.txt)
// x = 1 - f/n
// y = f/n
// z = 1/f - 1/n
// w = 1/n
// or in case of a reversed depth buffer (UNITY_REVERSED_Z is 1)
// x = -1 + f/n
// y = 1
// z = -1/n + -1/f
// w = 1/f
float4 _ZBufferParams;

// x = 1 or -1 (-1 if projection is flipped)
// y = near plane
// z = far plane
// w = 1/far plane
float4 _ProjectionParams;

// x = orthographic camera's width
// y = orthographic camera's height
// z = unused
// w = 1.0 if camera is ortho, 0.0 if perspective
float4 unity_OrthoParams;

// x = width
// y = height
// z = 1 + 1.0/width
// w = 1 + 1.0/height
float4 _ScreenParams;

float4 _FrustumPlanes[6];           // { (a, b, c) = N, d = -dot(N, P) } [L, R, T, B, N, F]

// TAA Frame Index ranges from 0 to 7.
// First two channels of this gives you two rotations per cycle. 
float4 _TaaFrameInfo;           // { sin(taaFrame * PI/2), cos(taaFrame * PI/2), taaFrame, taaEnabled ? 1 : 0 }
// t = animateMaterials ? Time.realtimeSinceStartup : 0.
float4 _Time;                       // { t/20, t, t*2, t*3 }
float4 _LastTime;                   // { t/20, t, t*2, t*3 }
float4 _SinTime;                    // { sin(t/8), sin(t/4), sin(t/2), sin(t) }
float4 _CosTime;                    // { cos(t/8), cos(t/4), cos(t/2), cos(t) }
float4 unity_DeltaTime;             // { dt, 1/dt, smoothdt, 1/smoothdt }
int _FrameCount;

// Volumetric lighting.
float4 _AmbientProbeCoeffs[7];      // 3 bands of SH, packed, rescaled and convolved with the phase function

float3 _HeightFogBaseScattering;
float  _HeightFogBaseExtinction;

float2 _HeightFogExponents;         // { 1/H, H }
float  _HeightFogBaseHeight;
float  _GlobalFogAnisotropy;

float4 _VBufferResolution;          // { w, h, 1/w, 1/h }
uint   _VBufferSliceCount;
float  _VBufferRcpSliceCount;
float  _Pad2;
float  _Pad3;
float4 _VBufferUvScaleAndLimit;     // Necessary us to work with sub-allocation (resource aliasing) in the RTHandle system
float4 _VBufferDistanceEncodingParams; // See the call site for description
float4 _VBufferDistanceDecodingParams; // See the call site for description

//#line 344 "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
float4x4 OptimizeProjectionMatrix(float4x4 M)
{
	// Matrix format (x = non-constant value).
	// Orthographic Perspective  Combined(OR)
	// | x 0 0 x |  | x 0 x 0 |  | x 0 x x |
	// | 0 x 0 x |  | 0 x x 0 |  | 0 x x x |
	// | x x x x |  | x x x x |  | x x x x | <- oblique projection row
	// | 0 0 0 1 |  | 0 0 x 0 |  | 0 0 x x |
	// Notice that some values are always 0.
	// We can avoid loading and doing math with constants.
	M._21_41 = 0;
	M._12_42 = 0;
	return M;
}

// Helper to handle camera relative space

float4x4 ApplyCameraTranslationToMatrix(float4x4 modelMatrix)
{
	// To handle camera relative rendering we substract the camera position in the model matrix
#if (SHADEROPTIONS_CAMERA_RELATIVE_RENDERING != 0)
	modelMatrix._m03_m13_m23 -= _WorldSpaceCameraPos;
#endif
	return modelMatrix;
}

float4x4 ApplyCameraTranslationToInverseMatrix(float4x4 inverseModelMatrix)
{
#if (SHADEROPTIONS_CAMERA_RELATIVE_RENDERING != 0)
	// To handle camera relative rendering we need to apply translation before converting to object space
	float4x4 translationMatrix = { { 1.0, 0.0, 0.0, _WorldSpaceCameraPos.x },{ 0.0, 1.0, 0.0, _WorldSpaceCameraPos.y },{ 0.0, 0.0, 1.0, _WorldSpaceCameraPos.z },{ 0.0, 0.0, 0.0, 1.0 } };
	return mul(inverseModelMatrix, translationMatrix);
#else
	return inverseModelMatrix;
#endif
}

#define LWRP_MATRIX 0
#if LWRP_MATRIX
//#line 6 "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
//#line 58 "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Input.hlsl"
#define UNITY_MATRIX_M     unity_ObjectToWorld
#define UNITY_MATRIX_I_M   unity_WorldToObject
#define UNITY_MATRIX_V     unity_MatrixV
#define UNITY_MATRIX_I_V   unity_MatrixInvV
#define UNITY_MATRIX_P     OptimizeProjectionMatrix(glstate_matrix_projection)
#define UNITY_MATRIX_I_P   ERROR_UNITY_MATRIX_I_P_IS_NOT_DEFINED
#define UNITY_MATRIX_VP    unity_MatrixVP
#define UNITY_MATRIX_I_VP  _InvCameraViewProj
#define UNITY_MATRIX_MV    mul(UNITY_MATRIX_V, UNITY_MATRIX_M)
#define UNITY_MATRIX_T_MV  transpose(UNITY_MATRIX_MV)
#define UNITY_MATRIX_IT_MV transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V))
#define UNITY_MATRIX_MVP   mul(UNITY_MATRIX_VP, UNITY_MATRIX_M)
#else
//#line 381 "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
// Define Model Matrix Macro
// Note: In order to be able to define our macro to forbid usage of unity_ObjectToWorld/unity_WorldToObject
// We need to declare inline function. Using uniform directly mean they are expand with the macro
float4x4 GetRawUnityObjectToWorld() { return unity_ObjectToWorld; }
float4x4 GetRawUnityWorldToObject() { return unity_WorldToObject; }

#define UNITY_MATRIX_M     ApplyCameraTranslationToMatrix(GetRawUnityObjectToWorld())
#define UNITY_MATRIX_I_M   ApplyCameraTranslationToInverseMatrix(GetRawUnityWorldToObject())

//#line 394 "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
// Define View/Projection matrix macro
//#line 21 "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariablesMatrixDefsHDCamera.hlsl"
#define UNITY_MATRIX_V     _ViewMatrix
#define UNITY_MATRIX_I_V   _InvViewMatrix
#define UNITY_MATRIX_P     OptimizeProjectionMatrix(_ProjMatrix)
#define UNITY_MATRIX_I_P   _InvProjMatrix
#define UNITY_MATRIX_VP    _ViewProjMatrix
#define UNITY_MATRIX_I_VP  _InvViewProjMatrix
#define UNITY_PREV_MATRIX_M   unity_MatrixPreviousM
#define UNITY_PREV_MATRIX_I_M unity_MatrixPreviousMI
#endif

//#line 401 "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
// This define allow to tell to unity instancing that we will use our camera relative functions (ApplyCameraTranslationToMatrix and  ApplyCameraTranslationToInverseMatrix) for the model view matrix
#define MODIFY_MATRIX_FOR_CAMERA_RELATIVE_RENDERING
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

//#line 4 "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariablesFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

#if 0
// This function always return the absolute position in WS
float3 GetAbsolutePositionWS(float3 positionRWS)
{
#if (SHADEROPTIONS_CAMERA_RELATIVE_RENDERING != 0)
	positionRWS += _WorldSpaceCameraPos;
#endif
	return positionRWS;
}

// This function return the camera relative position in WS
float3 GetCameraRelativePositionWS(float3 positionWS)
{
#if (SHADEROPTIONS_CAMERA_RELATIVE_RENDERING != 0)
	positionWS -= _WorldSpaceCameraPos;
#endif
	return positionWS;
}
#endif

// Return absolute world position of current object
float3 GetObjectAbsolutePositionWS()
{
	float4x4 modelMatrix = UNITY_MATRIX_M;
	return GetAbsolutePositionWS(modelMatrix._m03_m13_m23); // Translation object to world
}

float3 GetPrimaryCameraPosition()
{
#if (SHADEROPTIONS_CAMERA_RELATIVE_RENDERING != 0)
	return float3(0, 0, 0);
#else
	return _WorldSpaceCameraPos;
#endif
}

// Could be e.g. the position of a primary camera or a shadow-casting light.
float3 GetCurrentViewPosition()
{
#if (defined(SHADERPASS) && (SHADERPASS != SHADERPASS_SHADOWS)) && (!UNITY_SINGLE_PASS_STEREO) // Can't use camera position when rendering stereo
	return GetPrimaryCameraPosition();
#else
	// This is a generic solution.
	// However, using '_WorldSpaceCameraPos' is better for cache locality,
	// and in case we enable camera-relative rendering, we can statically set the position is 0.
	return UNITY_MATRIX_I_V._14_24_34;
#endif
}

// Returns the forward (central) direction of the current view in the world space.
float3 GetViewForwardDir()
{
	float4x4 viewMat = GetWorldToViewMatrix();
	return -viewMat[2].xyz;
}

// Returns the forward (up) direction of the current view in the world space.
float3 GetViewUpDir()
{
	float4x4 viewMat = GetWorldToViewMatrix();
	return viewMat[1].xyz;
}

// Returns 'true' if the current view performs a perspective projection.
bool IsPerspectiveProjection()
{
#if defined(SHADERPASS) && (SHADERPASS != SHADERPASS_SHADOWS)
	return (unity_OrthoParams.w == 0);
#else
	// This is a generic solution.
	// However, using 'unity_OrthoParams' is better for cache locality.
	// TODO: set 'unity_OrthoParams' during the shadow pass.
	return UNITY_MATRIX_P[3][3] == 0;
#endif
}

// Computes the world space view direction (pointing towards the viewer).
float3 GetWorldSpaceViewDir(float3 positionRWS)
{
	if (IsPerspectiveProjection())
	{
		// Perspective
		return GetCurrentViewPosition() - positionRWS;
	} else
	{
		// Orthographic
		return -GetViewForwardDir();
	}
}

float3 GetWorldSpaceNormalizeViewDir(float3 positionRWS)
{
	return normalize(GetWorldSpaceViewDir(positionRWS));
}

// UNITY_MATRIX_V defines a right-handed view space with the Z axis pointing towards the viewer.
// This function reverses the direction of the Z axis (so that it points forward),
// making the view space coordinate system left-handed.
void GetLeftHandedViewSpaceMatrices(out float4x4 viewMatrix, out float4x4 projMatrix)
{
	viewMatrix = UNITY_MATRIX_V;
	viewMatrix._31_32_33_34 = -viewMatrix._31_32_33_34;

	projMatrix = UNITY_MATRIX_P;
	projMatrix._13_23_33_43 = -projMatrix._13_23_33_43;
}

// This method should be used for rendering any full screen quad that uses an auto-scaling Render Targets (see RTHandle/HDCamera)
// It will account for the fact that the textures it samples are not necesarry using the full space of the render texture but only a partial viewport.
float2 GetNormalizedFullScreenTriangleTexCoord(uint vertexID)
{
	return GetFullScreenTriangleTexCoord(vertexID) * _ScreenToTargetScale.xy;
}

// The size of the render target can be larger than the size of the viewport.
// This function returns the fraction of the render target covered by the viewport:
// ViewportScale = ViewportResolution / RenderTargetResolution.
// Do not assume that their size is the same, or that sampling outside of the viewport returns 0.
float2 GetViewportScaleCurrentFrame()
{
	return _ScreenToTargetScale.xy;
}

float2 GetViewportScalePreviousFrame()
{
	return _ScreenToTargetScale.zw;
}

#if 0
float4 SampleSkyTexture(float3 texCoord, int sliceIndex)
{
	return SAMPLE_TEXTURECUBE_ARRAY(_SkyTexture, s_trilinear_clamp_sampler, texCoord, sliceIndex);
}

float4 SampleSkyTexture(float3 texCoord, float lod, int sliceIndex)
{
	return SAMPLE_TEXTURECUBE_ARRAY_LOD(_SkyTexture, s_trilinear_clamp_sampler, texCoord, sliceIndex, lod);
}
#endif

float2 TexCoordStereoOffset(float2 texCoord)
{
#if defined(UNITY_SINGLE_PASS_STEREO)
	return texCoord + float2(unity_StereoEyeIndex * _ScreenSize.x, 0.0);
#endif
	return texCoord;
}

// This function assumes the bitangent flip is encoded in tangentWS.w
float3x3 BuildWorldToTangent(float4 tangentWS, float3 normalWS)
{
	// tangentWS must not be normalized (mikkts requirement)

	// Normalize normalWS vector but keep the renormFactor to apply it to bitangent and tangent
	float3 unnormalizedNormalWS = normalWS;
	float renormFactor = 1.0 / length(unnormalizedNormalWS);

	// bitangent on the fly option in xnormal to reduce vertex shader outputs.
	// this is the mikktspace transformation (must use unnormalized attributes)
#if 1
	float3x3 worldToTangent = CreateTangentToWorld(unnormalizedNormalWS, tangentWS.xyz, tangentWS.w > 0.0 ? 1.0 : -1.0);
#else
	float sgn = (tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
	float3 bitangent = cross(unnormalizedNormalWS, tangentWS.xyz) * sgn;
	float3x3 worldToTangent = float3x3(tangentWS.xyz, bitangent, unnormalizedNormalWS);
#endif

	// surface gradient based formulation requires a unit length initial normal. We can maintain compliance with mikkts
	// by uniformly scaling all 3 vectors since normalization of the perturbed normal will cancel it.
	worldToTangent[0] = worldToTangent[0] * renormFactor;
	worldToTangent[1] = worldToTangent[1] * renormFactor;
	worldToTangent[2] = worldToTangent[2] * renormFactor;		// normalizes the interpolated vertex normal

	return worldToTangent;
}

// Z buffer to linear 0..1 depth
inline float Linear01Depth(float z)
{
	return 1.0 / (_ZBufferParams.x * z + _ZBufferParams.y);
}

inline half3 UnpackNormalDXT5nm(half4 packednormal)
{
	half3 normal;
	normal.xy = packednormal.wy * 2 - 1;
	normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
	return normal;
}

// Unpack normal as DXT5nm (1, y, 1, x) or BC5 (x, y, 0, 1)
// Note neutral texture like "bump" is (0, 0, 1, 1) to work with both plain RGB normal and DXT5nm/BC5
half3 UnpackNormalmapRGorAG(half4 packednormal)
{
	// This do the trick
	packednormal.x *= packednormal.w;

	half3 normal;
	normal.xy = packednormal.xy * 2 - 1;
	normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
	return normal;
}

inline half3 UnpackNormal(half4 packednormal)
{
#if defined(UNITY_NO_DXT5nm)
	return packednormal.xyz * 2 - 1;
#else
	return UnpackNormalmapRGorAG(packednormal);
#endif
}

half3 UnpackScaleNormalRGorAG(half4 packednormal, half bumpScale)
{
#if defined(UNITY_NO_DXT5nm)
	half3 normal = packednormal.xyz * 2 - 1;
//#if (SHADER_TARGET >= 30)
	// SM2.0: instruction count limitation
	// SM2.0: normal scaler is not supported
	normal.xy *= bumpScale;
//#endif
	return normal;
#else
	// This do the trick
	packednormal.x *= packednormal.w;

	half3 normal;
	normal.xy = (packednormal.xy * 2 - 1);
//#if (SHADER_TARGET >= 30)
	// SM2.0: instruction count limitation
	// SM2.0: normal scaler is not supported
	normal.xy *= bumpScale;
//#endif
	normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
	return normal;
#endif
}

half3 UnpackScaleNormal(half4 packednormal, half bumpScale)
{
	return UnpackScaleNormalRGorAG(packednormal, bumpScale);
}

half3 BlendNormals(half3 n1, half3 n2)
{
	return normalize(half3(n1.xy + n2.xy, n1.z * n2.z));
}

#endif // DENA_COMMON_HLSL


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////¥H¤U¬°RYU////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef RYU_COMMON_HLSL
#define RYU_COMMON_HLSL

float4 TransformBlitToHClip(float3 pos) {
	float4 v = float4(2, 2, -1, -1);
	v.yw *= _ProjectionParams.x;
	pos.xy = pos.xy * v.xy + v.zw;
	return float4(pos, 1);
}

void TransformBackground(out float4 positionCS, in float3 positionOS, bool bRelative = false) {
	float4x4 m = bRelative ? GetObjectToWorldMatrix() : GetRawUnityObjectToWorld();
	float3 positionRWS = mul((float3x4)m, float4(positionOS, 1));
	//	float3 positionRWS = mul((float3x3)m, positionOS + m._m03_m13_m23);
	positionCS = TransformWorldToHClip(positionRWS);
	positionCS.z = UNITY_RAW_FAR_CLIP_VALUE * positionCS.w;
#if UNITY_REVERSED_Z
	//	positionCS.z = max(positionCS.z, UNITY_RAW_FAR_CLIP_VALUE * positionCS.w);
#else
	//	positionCS.z = min(positionCS.z, UNITY_RAW_FAR_CLIP_VALUE * positionCS.w);
#endif
}

void DitherClip(float2 pixelPos, half alpha) {
	const half4x4 threshold = {
		0.001,			8.0 / 15.0,		2.0 / 15.0,		10.0 / 15.0,
		12.0 / 15.0,	4.0 / 15.0,		14.0 / 15.0,	6.0 / 15.0,
		3.0 / 15.0,		11.0 / 15.0,	1.0 / 15.0,		9.0 / 15.0,
		1,				7.0 / 15.0,		13.0 / 15.0,	5.0 / 15.0,
	};

	float2 p = fmod(pixelPos, 4);
	half a = threshold[p.x][p.y];
	clip(alpha - a);
}

float _DitherAlpha;

void DitherClip(float2 pixelPos) {
	DitherClip(pixelPos, _DitherAlpha);
}

//float4 _V_CW_PivotPoint_Position;
//float4 _V_CW_Bend;
//float4 _V_CW_Bias;
float4 _GlobalBendParams;

float3 GlobalBendOffset(float3 positionRWS) {
	float3 offset = positionRWS;// -_V_CW_PivotPoint_Position.xyz;

	//float3 xyzOff = max(float3(0, 0, 0), abs(offset.zzx) - _V_CW_Bias.xyz);
	float3 xyzOff = max(float3(0, 0, 0), abs(offset.zzx) - _GlobalBendParams.zzz);
	xyzOff *= step(float3(0, 0, 0), offset.zzx) * 2 - 1;
	xyzOff *= xyzOff;
	//	offset = float3(-_V_CW_Bend.y * xyzOff.y, _V_CW_Bend.x * xyzOff.x + _V_CW_Bend.z * xyzOff.z, 0.0f) * 0.001;
	offset = 0.001 * float3(_GlobalBendParams.xy * xyzOff.xy, 0.0);

	return offset;
}

float3 GlobalBendOffset() {
	return GlobalBendOffset(GetObjectToWorldMatrix()._m03_m13_m23);
}

TEXTURE2D(_GeomTex);
SAMPLER(sampler_GeomTex);
TEXTURE2D(_LightTex);
SAMPLER(sampler_LightTex);
TEXTURE2D(_ShadowTex);
SAMPLER(sampler_ShadowTex);
TEXTURE2D(_ScreenTex);
SAMPLER(sampler_ScreenTex);
TEXTURE2D(_ReflTex);
SAMPLER(sampler_ReflTex);

float4 _RenderParams[1];
float4 _LightingParams[6];
float4 _CloudParams[1];
float4 _WavingParams[2];
#define _RenderSize (_RenderParams[0])
#define _GlobalEmissiveIntensity (_LightingParams[0].w)
#define _SceneMultiplierBG (_LightingParams[0].rgb)
#define _SceneMultiplierFG (_LightingParams[1].rgb)
#define _CloudShadowIntensity (_LightingParams[5].x)
#define _ShadowProjectorIntensity (_LightingParams[5].y)

half4 Gamma20ToLinearShadow(half4 v) {
	v = 1.0h - v;
	v *= v;
	return 1.0h - v;
}

half3 Lighting(float2 screen, half3 color, bool bShadow = false) {
	color = Gamma20ToLinear(color);
	half3 light = SAMPLE_TEXTURE2D(_LightTex, sampler_LightTex, screen).xyz;
	half4 shadow = bShadow ? SAMPLE_TEXTURE2D(_ShadowTex, sampler_ShadowTex, screen) : 0;
	color *= light + 0.5h * (1 - shadow.rgb);
	return LinearToGamma20(color);
}

half3 LightingBackground(half3 color) {
	color = Gamma20ToLinear(color);
	color *= _LightingParams[2].rgb;
	return LinearToGamma20(color);
}

half3 LightingProp(float2 screen, half3 color, half shade) {
	half4 shadow = SAMPLE_TEXTURE2D(_ShadowTex, sampler_ShadowTex, screen);
	half3 light = SAMPLE_TEXTURE2D(_LightTex, sampler_LightTex, screen).rgb;

	shadow = Gamma20ToLinearShadow(shadow);
	color = Gamma20ToLinear(color);
	half3 v0 = lerp(_LightingParams[2].rgb, _LightingParams[3].rgb * (1 - _LightingParams[5].z * shadow.a), max(1 - shade, shadow.rgb));
	half3 v1 = lerp(_LightingParams[2].rgb, _LightingParams[4].rgb, shadow.a);
	color *= min(v0, v1) + light;
	return LinearToGamma20(color);
}

half3 LightingTerrain(float2 screen, half3 color) {
	return LightingProp(screen, color, 1);
}

half3 LightingEffect(float2 screen, half3 color) {
	return LightingProp(screen, color, 1);
}

half3 LightingCharacter(float2 screen, half3 color, half3 lightColor, half3 shadowColor, half3 ao, half3 reflection) {
	half4 shadow = SAMPLE_TEXTURE2D(_ShadowTex, sampler_ShadowTex, screen);
	half3 light = SAMPLE_TEXTURE2D(_LightTex, sampler_LightTex, screen).rgb;

	shadow = Gamma20ToLinearShadow(shadow);
	ao = Gamma20ToLinear(ao);
	reflection = Gamma20ToLinear(reflection);
	color = Gamma20ToLinear(color);
	color *= ao * lerp(lightColor, shadowColor, shadow.rgb) + light;
	color += (1.0h - shadow.rgb) * reflection;
	return LinearToGamma20(color);
}

float4 _FogParams[3];

half4 ApplyFog(half4 color, float3 positionRWS) {
	half l = length(positionRWS);
	half2 f = max(0, l - _FogParams[2].xy) * _FogParams[2].zw;
	f = min(half2(_FogParams[0].a, _FogParams[1].a), f);
	color = lerp(color, half4(_FogParams[0].rgb, 0), f.x);
	color.rgb += _FogParams[1].rgb * f.y;
	return color;
}

half4 ApplyFog(half4 color) {
	color = lerp(color, half4(_FogParams[0].rgb, 0), _FogParams[0].a);
	color.rgb += _FogParams[1].rgb * _FogParams[1].a;
	return color;
}

#define ENCODE_HDR(v) (exp(-(v)))
#define DECODE_HDR(v) (-log(max(0.5h / 255.0h, (v))))

half4 EncodeOpaque(half4 value, half intensity) {
	value.a = ENCODE_HDR(intensity * value.a);
	return value;
}

half4 EncodeOpaque(half4 value) {
	return EncodeOpaque(value, _GlobalEmissiveIntensity);
}

half SoftParticle(float2 positionCS, half3 positionRWS, half intensity) {
	half4 t = SAMPLE_TEXTURE2D_LOD(_GeomTex, sampler_GeomTex, _RenderSize.zw * positionCS, 0);
	return t.w != 0 ? saturate(intensity * length(positionRWS - t.xyz)) : 1;
}

TEXTURE2D(_OccTex);
SAMPLER(sampler_OccTex);

float4 _GlobalOccParams[1];
float4 _OccParams;

int GetParticleID(uint vertexID) {
	return (int)_OccParams.x + (vertexID >> 2);
}

half GetEffectVisibility(int particleID) {
	half u = _GlobalOccParams[0].x * (particleID + 0.5h);
	return SAMPLE_TEXTURE2D_LOD(_OccTex, sampler_OccTex, half2(u, 0.5), 0).x;
}

#endif // RYU_COMMON_HLSL
