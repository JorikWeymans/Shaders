float4x4 gWorld : WORLD;
float4x4 gWorldViewProj : WORLDVIEWPROJECTION; 
float4x4 gWorldViewProj_Light;
float3 gLightDirection = float3(-0.577f, -0.577f, 0.577f);
float gShadowMapBias = 0.01f;
float4x4 gBones[70];

Texture2D gDiffuseMap;
Texture2D gShadowMap;

SamplerComparisonState cmpSampler
{
	// sampler state
	Filter = COMPARISON_MIN_MAG_MIP_LINEAR;
	AddressU = MIRROR;
	AddressV = MIRROR;

	// sampler comparison state
	ComparisonFunc = LESS_EQUAL;
};

SamplerState samLinear
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;// or Mirror or Clamp or Border
    AddressV = Wrap;// or Mirror or Clamp or Border
};

struct VS_INPUT
{
	float3 pos : POSITION;
	float3 normal : NORMAL;
	float2 texCoord : TEXCOORD;
	float4 BoneIndices : BLENDINDICES;
	float4 BoneWeights : BLENDWEIGHTS;
};

struct VS_OUTPUT
{
	float4 pos : SV_POSITION;
	float3 normal : NORMAL;
	float2 texCoord : TEXCOORD;
	float4 lPos : TEXCOORD1;
};

DepthStencilState EnableDepth
{
	DepthEnable = TRUE;
	DepthWriteMask = ALL;
};

RasterizerState NoCulling
{
	CullMode = NONE;
};

//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
VS_OUTPUT VS(VS_INPUT input)
{
	VS_OUTPUT output;

	float4 originalPosition = float4(input.pos, 1);
	float4 transformedPosition = 0;
	float3 transformedNormal = 0;

	//Skinning Magic...
	
	for(int i = 0; i < 4; ++i)
	{
		int idx = input.BoneIndices[i];
		if(idx > -1) //check if the index exists
		{
			transformedPosition += mul(originalPosition, gBones[idx]) * input.BoneWeights[i];
			transformedNormal += mul(originalPosition, (float3x3)gBones[idx]) * input.BoneWeights[i];
		}
	}

	//Don't forget to change the output.pos & output.normal variables...
	transformedPosition.w = 1;
	
	output.pos = mul(transformedPosition, gWorldViewProj ); //Non skinned pos
	output.normal = normalize(mul(transformedNormal, (float3x3)gWorld)); //Non skinned norm
	output.lPos =  mul(transformedPosition, gWorldViewProj_Light);
	output.texCoord = input.texCoord;
	return output;
	
}

float2 texOffset(int u, int v)
{
	//TODO: return offseted value (our shadow map has the following dimensions: 1280 * 720)
	return float2( u * 1.0f/1280, v * 1.0f/720 );
}

float EvaluateShadowMap(float4 lpos)
{
	//TODO: complete
	lpos.xyz /= lpos.w;
	
	if(lpos.x < -1.0f || lpos.x > 1.0f ||
       lpos.y < -1.0f || lpos.y > 1.0f ||
       lpos.z < 0.0f  || lpos.z > 1.0f ) 
	return 0.5f;
	
	lpos.x = lpos.x/2 + 0.5;
    lpos.y = lpos.y/-2 + 0.5;
	lpos.z -= gShadowMapBias;
	
	//float shadowMapDepth = gShadowMap.Sample(samLinear, lpos.xy).r;
	float shadowFactor = gShadowMap.SampleCmpLevelZero( cmpSampler, lpos.xy, lpos.z );
	if ( shadowFactor < lpos.z) return 0.3f;
	return 1.f;
}

//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS(VS_OUTPUT input) : SV_TARGET
{
	float shadowValue = EvaluateShadowMap(input.lPos);

	float4 diffuseColor = gDiffuseMap.Sample( samLinear,input.texCoord );
	float3 color_rgb= diffuseColor.rgb;
	float color_a = diffuseColor.a;
	
	//HalfLambert Diffuse :)
	float diffuseStrength = dot(input.normal, -gLightDirection);
	diffuseStrength = diffuseStrength * 0.5 + 0.5;
	diffuseStrength = saturate(diffuseStrength);
	color_rgb = color_rgb * diffuseStrength;

	return float4( color_rgb * shadowValue, color_a );
}

//--------------------------------------------------------------------------------------
// Technique
//--------------------------------------------------------------------------------------
technique11 Default
{
    pass P0
    {
		SetRasterizerState(NoCulling);
		SetDepthStencilState(EnableDepth, 0);

		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader( NULL );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}

