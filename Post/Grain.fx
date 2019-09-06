//=============================================================================
//// Shader uses position and texture
//=============================================================================
SamplerState samPoint
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Mirror;
    AddressV = Mirror;
};

Texture2D gTexture;
float gStrength = 16.f;
float gTime = 1.0f;
bool gEnabled = true;
/// Create Depth Stencil State (ENABLE DEPTH WRITING)
DepthStencilState depthStencilState
{
	DepthEnable = TRUE;
};
/// Create Rasterizer State (Backface culling) 
RasterizerState BackCulling
{
	CullMode = BACK;
};
//IN/OUT STRUCTS
//--------------
struct VS_INPUT
{
    float3 Position : POSITION;
	float2 TexCoord : TEXCOORD0;
};

struct PS_INPUT
{
    float4 Position : SV_POSITION;
	float2 TexCoord : TEXCOORD1;
	//uint id : SV_VertexID;
};


//VERTEX SHADER
//-------------
PS_INPUT VS(VS_INPUT input)
{
	PS_INPUT output = (PS_INPUT)0;
	// Set the Position1
	output.Position = float4(input.Position, 1.f);

	// Set the TexCoord
	output.TexCoord = input.TexCoord;
	return output;
}


//PIXEL SHADER
//------------
float4 PS(PS_INPUT input): SV_Target
{
	float3 color = gTexture.Sample(samPoint,input.TexCoord);
	
	if(!gEnabled) return float4(color, 1.0f);
	
	float sampledPoint = (input.TexCoord.x + 4.0) *  (input.TexCoord.y + 4.0) * gTime * 10.f;
	
	float seed = (sampledPoint % 100.0) + 1.0;
	float temp = (seed * seed) % 0.01f;
	
	float4 grain = 1.0f -  (float4) ((temp % -0.005f ) * gStrength);
	return float4(color * grain.xyz, 1.0f);

}


//TECHNIQUE
//---------
technique11 Blur
{
    pass P0
    {
		// Set states...
		SetDepthStencilState(depthStencilState, 0);
        SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetRasterizerState(BackCulling);  
        SetGeometryShader( NULL );
        SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}