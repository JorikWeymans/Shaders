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
float gAberationAmount =  2.1;
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
	if(!gEnabled) return  float4(gTexture.Sample(samPoint,input.TexCoord).xyz, 1.0f);
	
	float realAbAmount = gAberationAmount * 0.001; //using this so it is more easy to control
	float4 abColor;
	float2 texCoordOffset = input.TexCoord;
	
	texCoordOffset.x += realAbAmount;
	texCoordOffset.y +=realAbAmount;
	abColor.x = gTexture.Sample(samPoint,texCoordOffset).x;
	
	texCoordOffset.x -= (realAbAmount * 2);
	abColor.y = gTexture.Sample(samPoint,texCoordOffset).y;
	
	texCoordOffset.y -=(realAbAmount * 2);
	abColor.z = gTexture.Sample(samPoint,texCoordOffset).z;
	
	abColor.a = 1.0f;
	return abColor;
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