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

DepthStencilState depthStencilState
{
	DepthEnable = TRUE;
};

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

	output.Position = float4(input.Position, 1.f);

	output.TexCoord = input.TexCoord;
	return output;
}


//PIXEL SHADER
//------------
float4 PS(PS_INPUT input): SV_Target
{
	float3 color = gTexture.Sample(samPoint, input.TexCoord);

	float grayscale = (color.x + color.y + color.z )/ 3;

	return float4( grayscale, grayscale, grayscale, 1.0f );
	//sepia
    return float4( grayscale * 1.02, grayscale * .56, grayscale * .1f, 1.0f );
}


//TECHNIQUE
//---------
technique11 TechGrayscale
{
    pass P0
    {          
		SetDepthStencilState(depthStencilState, 0);
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetRasterizerState(BackCulling);    
        SetGeometryShader( NULL );
        SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}

