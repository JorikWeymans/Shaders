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
	uint width, height;
	gTexture.GetDimensions(width, height);	

	float dx = 1.f / width;
	float dy = 1.f / height;
	float2 topLeftPos = float2(input.TexCoord.x - 2 *  dx, input.TexCoord.y - 2 *  dy);
	
	float3 color;
	int sampleTimes = 0;
	for(int i = 0; i < 5; ++i)
	{
		for(int j = 0; j < 5; ++j)
		{
			float2 currPos = float2(topLeftPos.x + (j * dx),topLeftPos.y + (i * dy));
			if(!(currPos.x < 0 || currPos.y < 0))
			{
				color += gTexture.Sample(samPoint,currPos);
				++sampleTimes;
			}
			
		}
	}

	color /= sampleTimes;

	return float4(color, 1.0f);
}


//TECHNIQUE
//---------
technique11 TechBlur
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