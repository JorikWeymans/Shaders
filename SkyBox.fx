SamplerState samLinear
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};
DepthStencilState depthStencilState
{
	DepthFunc = LESS_EQUAL;
};
RasterizerState noCullRasterizer 
{ 
	CullMode = NONE; 
};
TextureCube m_CubeMap : CubeMap;

cbuffer cbChangesEveryFrame
{
	matrix matWorldViewProj : WorldViewProjection;
}

struct VS_IN
{
	float3 posL : POSITION;
};

struct VS_OUT
{
	float4 posH : SV_POSITION;
	float3 texC : TEXCOORD;
};

//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
VS_OUT VS( VS_IN vIn )
{
	VS_OUT vOut = (VS_OUT)0;
	vOut.posH = mul(float4(vIn.posL,0.0f), matWorldViewProj).xyww;
	vOut.posH.z = vOut.posH.w;
	vOut.texC = (vIn.posL);
	
	return vOut;
}
//--------------------------------------------------------------------------------------
// Pixel XMeshShader
//--------------------------------------------------------------------------------------
float4 PS( VS_OUT pIn): SV_Target
{
	float3 color = (float3)0;
	color = m_CubeMap.Sample(samLinear, pIn.texC);
	
	return float4(color, 1.0f);
}

technique10 TechSkyBox
{
    pass P0
    {
		SetDepthStencilState(depthStencilState, 0);
		SetRasterizerState(noCullRasterizer);
        SetVertexShader( CompileShader( vs_4_0, VS() ) );
        SetGeometryShader( NULL );
        SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}