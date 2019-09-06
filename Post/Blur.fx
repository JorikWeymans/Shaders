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
	// Step 1: find the dimensions of the texture (the texture has a method for that)
	uint width, height;
	gTexture.GetDimensions(width, height);	
	// Step 2: calculate dx and dy (UV space for 1 pixel)	
	float dx = 1.f / width;
	float dy = 1.f / height;
	float2 topLeftPos = float2(input.TexCoord.x - 2 *  dx, input.TexCoord.y - 2 *  dy);
	
	// Step 3: Create a double for loop (5 iterations each)
	float3 color;
	int sampleTimes = 0; // counting because if the uv coor is invalid we dont sample so the color divide is one less;
	for(int i = 0; i < 5; ++i)
	{
		//Inside the loop, calculate the offset in each direction. Make sure not to take every pixel but move by 2 pixels each time
		//Do a texture lookup using your previously calculated uv coordinates + the offset, and add to the final color
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
	// Step 4: Divide the final color by the number of passes (in this case 5*5)
	color /= sampleTimes;
	// Step 5: return the final color
	return float4(color, 1.0f);
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