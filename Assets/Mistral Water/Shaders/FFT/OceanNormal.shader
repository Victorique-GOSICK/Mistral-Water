﻿Shader "Hidden/Mistral Water/Helper/Map/Ocean Normal"
{
	Properties
	{
		_DisplacementMap ("Displacement Map", 2D) = "black" {}
		_Length ("Wave Length", Float) = 512
		_Resolution ("Resolution", Float) = 512
	}

	SubShader
	{
		Pass
		{
			Cull Off
			ZWrite Off
			ZTest Off
			ColorMask RGBA

			CGPROGRAM

			#include "FFTCommon.cginc"

			#pragma vertex vert_quad
			#pragma fragment frag

			uniform sampler2D _DisplacementMap;
			uniform float _Length;
			uniform float _Resolution;

			float4 frag(FFTVertexOutput i) : SV_TARGET
			{
				float texel = 1 / _Resolution;
				float texelSize = _Length / _Resolution;

				float3 center = tex2D(_DisplacementMap, i.texcoord).rgb / 8;
				float3 right = float3(texelSize, 0, 0) / 8 + tex2D(_DisplacementMap, i.texcoord + float4(texel, 0, 0, 0)).rgb / 8 - center;
				float3 left = float3(-texelSize, 0, 0) / 8 + tex2D(_DisplacementMap, i.texcoord + float4(-texel, 0, 0, 0)).rgb / 8 - center;
				float3 top = float3(0, 0, -texelSize) / 8 + tex2D(_DisplacementMap, i.texcoord + float4(0, -texel, 0, 0)).rgb / 8 - center;
				float3 bottom = float3(0, 0, texelSize) / 8 + tex2D(_DisplacementMap, i.texcoord + float4(0, texel, 0, 0)).rgb / 8 - center;

				float3 topRight = cross(right, top);
				float3 topLeft = cross(top, left);
				float3 bottomLeft = cross(left, bottom);
				float3 bottomRight = cross(bottom, right);

				//return float4(normalize(float3(abs(tex2D(_DisplacementMap, i.texcoord).r), 8, abs(tex2D(_DisplacementMap, i.texcoord).b))), 1.0);

				return float4(normalize(topRight + topLeft + bottomLeft + bottomRight), 1.0);
			}

			ENDCG
		}
	}
}