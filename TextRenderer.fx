float4x4 gTransform : WORLDVIEWPROJECTION;
Texture2D gSpriteTexture;
float2 gTextureSize;

SamplerState samPoint
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = WRAP;
    AddressV = WRAP;
};

BlendState EnableBlending 
{     
	BlendEnable[0] = TRUE;
	SrcBlend = SRC_ALPHA;
    DestBlend = INV_SRC_ALPHA;
};

RasterizerState BackCulling 
{ 
	CullMode = BACK; 
};

//SHADER STRUCTS
//**************
struct VS_DATA
{
	int Channel : TEXCOORD2; 
	float3 Position : POSITION; 
	float4 Color: COLOR; 
	float2 TexCoord: TEXCOORD0; 
	float2 CharSize: TEXCOORD1; 
};

struct GS_DATA
{
	float4 Position : SV_POSITION; 
	float4 Color	: COLOR;
	float2 TexCoord	: TEXCOORD0; 
	int Channel		: TEXCOORD1; 
};

//VERTEX SHADER
//*************
VS_DATA MainVS(VS_DATA input)
{
	return input;
}

//GEOMETRY SHADER
//***************
void CreateVertex(inout TriangleStream<GS_DATA> triStream, float3 pos, float4 col, float2 texCoord, int channel)
{
	GS_DATA GSData = (GS_DATA)0;
	
	GSData.Position = mul(float4(pos, 1),gTransform);
	GSData.Color = col;
	GSData.TexCoord = texCoord;
	GSData.Channel = channel;
	triStream.Append(GSData);
	
	
}

[maxvertexcount(4)]
void MainGS(point VS_DATA vertex[1], inout TriangleStream<GS_DATA> triStream)
{

	CreateVertex(triStream, vertex[0].Position, vertex[0].Color, vertex[0].TexCoord, vertex[0].Channel);
		vertex[0].Position.x += vertex[0].CharSize.x;
		vertex[0].TexCoord.x += vertex[0].CharSize.x / gTextureSize.x;
	
	CreateVertex(triStream, vertex[0].Position, vertex[0].Color, vertex[0].TexCoord, vertex[0].Channel);
		vertex[0].Position.x -= vertex[0].CharSize.x;
		vertex[0].Position.y += vertex[0].CharSize.y;
		vertex[0].TexCoord.x -= vertex[0].CharSize.x / gTextureSize.x;
		vertex[0].TexCoord.y += vertex[0].CharSize.y / gTextureSize.y;

	
	CreateVertex(triStream, vertex[0].Position, vertex[0].Color, vertex[0].TexCoord, vertex[0].Channel);
	    vertex[0].Position.x += vertex[0].CharSize.x;
		vertex[0].TexCoord.x += vertex[0].CharSize.x / gTextureSize.x;
		
	
	CreateVertex(triStream, vertex[0].Position, vertex[0].Color, vertex[0].TexCoord, vertex[0].Channel);
}

//PIXEL SHADER
//************
float4 MainPS(GS_DATA input) : SV_TARGET {
	
	float4 color = gSpriteTexture.Sample(samPoint,input.TexCoord)[input.Channel] * input.Color;
    return color; //TEMP
}

technique10 TechTexRenderer {

	pass p0 {
		SetRasterizerState(BackCulling);
		SetBlendState(EnableBlending,float4(0.0f, 0.0f, 0.0f, 0.0f), 0xFFFFFFFF);
		SetVertexShader(CompileShader(vs_4_0, MainVS()));
		SetGeometryShader(CompileShader(gs_4_0, MainGS()));
		SetPixelShader(CompileShader(ps_4_0, MainPS()));
	}
}
