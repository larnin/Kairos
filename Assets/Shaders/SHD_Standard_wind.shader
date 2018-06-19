// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SHD_Standard_Wind"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Float) = 1
		_Tiling("Tiling", Vector) = (0,0,0,0)
		_MouvSpeed("MouvSpeed", Float) = 0
		_Color("Color ", Color) = (0,0,0,0)
		_MouvStrength("MouvStrength", Float) = 0
		_Emission("Emission", Float) = 0
		_Emissivecolor("Emissivecolor", Color) = (0,0,0,0)
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 texcoord_0;
			float2 texcoord_1;
		};

		uniform float _NormalIntensity;
		uniform sampler2D _NormalMap;
		uniform float2 _Tiling;
		uniform float4 _Color;
		uniform float _Emission;
		uniform float4 _Emissivecolor;
		uniform float _MouvSpeed;
		uniform float _MouvStrength;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * _Tiling + float2( 0,0 );
			float3 appendResult103 = (float3(1.0 , 0.0 , 1.0));
			o.texcoord_1.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			v.vertex.xyz += ( sin( ( _Time.y * _MouvSpeed ) ) * _MouvStrength * appendResult103 * o.texcoord_1.y );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = UnpackScaleNormal( tex2D( _NormalMap, i.texcoord_0 ) ,_NormalIntensity );
			o.Albedo = _Color.rgb;
			o.Emission = ( _Emission * _Emissivecolor ).rgb;
			float temp_output_101_0 = 0.0;
			o.Metallic = temp_output_101_0;
			o.Smoothness = temp_output_101_0;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
1927;94;1906;939;475.7036;51.8743;1.400212;True;False
Node;AmplifyShaderEditor.RangedFloatNode;97;627.9671,683.6723;Float;False;Property;_MouvSpeed;MouvSpeed;10;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleTimeNode;106;491.7754,846.2211;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;670.6281,846.2212;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.Vector2Node;7;-1279.595,129.6514;Float;False;Property;_Tiling;Tiling;6;0;0,0;0;3;FLOAT2;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;103;1365.226,728.001;Float;False;FLOAT3;4;0;FLOAT;1.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;0.0;False;1;FLOAT3
Node;AmplifyShaderEditor.RangedFloatNode;89;675.0062,115.4491;Float;False;Property;_Emission;Emission;15;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;108;361.2072,484.141;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SinOpNode;105;830.2756,847.4214;Float;True;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;100;1312.42,638.0496;Float;False;Property;_MouvStrength;MouvStrength;11;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;4;-765,179.5;Float;False;Property;_NormalIntensity;Normal Intensity;4;0;1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;91;1104.881,110.4176;Float;False;Property;_Emissivecolor;Emissivecolor;16;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-1085.997,129.6517;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;1335.823,46.43409;Float;False;2;2;0;FLOAT;0,0,0,0;False;1;COLOR;0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;1476.42,449.0496;Float;False;4;4;0;FLOAT;0,0,0,0;False;1;FLOAT;0,0,0,0;False;2;FLOAT3;0;False;3;FLOAT;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.ColorNode;102;1206.886,-120.1354;Float;False;Property;_Color;Color ;10;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;101;1177.427,291.6857;Float;False;Constant;_Float0;Float 0;12;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;3;-526,133.5;Float;True;Property;_NormalMap;Normal Map;3;0;Assets/Textures/T_textured_soft_paint02_normal.png;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1786.166,-3.378693;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/SHD_Standard_Wind;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;107;0;106;0
WireConnection;107;1;97;0
WireConnection;105;0;107;0
WireConnection;8;0;7;0
WireConnection;90;0;89;0
WireConnection;90;1;91;0
WireConnection;99;0;105;0
WireConnection;99;1;100;0
WireConnection;99;2;103;0
WireConnection;99;3;108;2
WireConnection;3;1;8;0
WireConnection;3;5;4;0
WireConnection;0;0;102;0
WireConnection;0;1;3;0
WireConnection;0;2;90;0
WireConnection;0;3;101;0
WireConnection;0;4;101;0
WireConnection;0;11;99;0
ASEEND*/
//CHKSM=595EBEFFC50A3A8C90495807A1C36C04E32205AC