// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SimpleRefraction 1"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_BrushedMetalNormal("BrushedMetalNormal", 2D) = "bump" {}
		_Distortion("Distortion", Range( 0 , 1)) = 0.292
		_MouvSpeed("MouvSpeed", Range( -1 , 1)) = 0.5187306
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Overlay+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZTest LEqual
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPos;
			float2 texcoord_0;
			float eyeDepth;
			float3 worldPos;
			float3 worldNormal;
		};

		uniform sampler2D _GrabTexture;
		uniform sampler2D _BrushedMetalNormal;
		uniform float _MouvSpeed;
		uniform float _Distortion;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
			o.texcoord_0.xy = v.texcoord.xy * float2( 0.5,0.5 ) + float2( 0,0 );
		}

		inline fixed4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return fixed4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPos40 = ase_screenPos;
			#if UNITY_UV_STARTS_AT_TOP
			float scale40 = -1.0;
			#else
			float scale40 = 1.0;
			#endif
			float halfPosW40 = ase_screenPos40.w * 0.5;
			ase_screenPos40.y = ( ase_screenPos40.y - halfPosW40 ) * _ProjectionParams.x* scale40 + halfPosW40;
			#ifdef UNITY_SINGLE_PASS_STEREO
			ase_screenPos40.xy = TransformStereoScreenSpaceTex(ase_screenPos40.xy, ase_screenPos40.w);
			#endif
			ase_screenPos40.xyzw /= ase_screenPos40.w;
			float2 componentMask39 = ase_screenPos40.xy;
			float mulTime54 = _Time.y * _MouvSpeed;
			float2 panner53 = ( i.texcoord_0 + mulTime54 * float2( 0.2,1 ));
			float cameraDepthFade60 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 10.0);
			float lerpResult64 = lerp( _Distortion , 0.0 , saturate( cameraDepthFade60 ));
			float3 ase_worldPos = i.worldPos;
			fixed3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNode46 = ( 0.0 + 5.0 * pow( 1.0 - dot( ase_worldNormal, ase_worldViewDir ), 1.0 ) );
			float2 componentMask36 = ( UnpackNormal( tex2D( _BrushedMetalNormal, panner53 ) ) * saturate( ( lerpResult64 * saturate( ( 1.0 - fresnelNode46 ) ) ) ) ).xy;
			float4 screenColor8 = tex2D( _GrabTexture, ( componentMask39 + componentMask36 ) );
			o.Emission = screenColor8.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13201
2069;93;1684;906;1030.392;327.4901;1.458651;True;True
Node;AmplifyShaderEditor.CameraDepthFade;60;-824.7939,1039.387;Float;False;2;0;FLOAT;10.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.FresnelNode;46;-1301.782,633.742;Float;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;5.0;False;3;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;63;-589.2814,1051.729;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;56;-1920.875,333.3193;Float;False;Property;_MouvSpeed;MouvSpeed;3;0;0.5187306;-1;1;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;31;-1284.028,477.2637;Float;False;Property;_Distortion;Distortion;1;0;0.292;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;66;-872.0329,858.2513;Float;False;Constant;_Float1;Float 1;5;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;50;-1009.928,650.6259;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.TextureCoordinatesNode;57;-1702.313,127.0516;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleTimeNode;54;-1609.422,284.1427;Float;False;1;0;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;64;-565.176,661.3499;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;47;-794.1273,546.6263;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-626.4271,467.3261;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.PannerNode;53;-1389.496,229.5024;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.2,1;False;1;FLOAT;1.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SamplerNode;29;-1082.48,216.599;Float;True;Property;_BrushedMetalNormal;BrushedMetalNormal;0;0;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;49;-466.5276,466.2347;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.GrabScreenPosition;40;-447.4607,49.29217;Float;False;0;0;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-441.6739,287.2988;Float;False;2;2;0;FLOAT3;0.0,0,0;False;1;FLOAT;0.0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.ComponentMaskNode;36;-248.5805,285.0987;Float;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.ComponentMaskNode;39;-191.7806,65.19897;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleAddOpNode;30;36.62508,137.2995;Float;False;2;2;0;FLOAT2;0.0,0;False;1;FLOAT2;0.0,0,0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.OneMinusNode;61;40.60557,794.9349;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-905.4437,423.58;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;41;-884.0697,3.451569;Float;True;Property;_T_Paint02;T_Paint02;2;0;Assets/Textures/T_Paint02.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;51;205.1668,348.8158;Float;True;Constant;_Float0;Float 0;4;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.ScreenColorNode;8;224.0004,85.8997;Float;False;Global;_ScreenGrab0;Screen Grab 0;-1;0;Object;-1;False;1;0;FLOAT2;0,0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ScreenColorNode;52;183.5083,-97.6752;Float;False;Global;_GrabScreen1;Grab Screen 1;-1;0;Object;-1;False;1;0;FLOAT2;0,0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;536.7999,-33.8;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;SimpleRefraction 1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;Back;0;3;False;0;0;Custom;0.5;True;False;0;True;Transparent;Overlay;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;False;0;Zero;Zero;0;Zero;Zero;Add;Add;1;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;63;0;60;0
WireConnection;50;0;46;0
WireConnection;54;0;56;0
WireConnection;64;0;31;0
WireConnection;64;1;66;0
WireConnection;64;2;63;0
WireConnection;47;0;50;0
WireConnection;48;0;64;0
WireConnection;48;1;47;0
WireConnection;53;0;57;0
WireConnection;53;1;54;0
WireConnection;29;1;53;0
WireConnection;49;0;48;0
WireConnection;32;0;29;0
WireConnection;32;1;49;0
WireConnection;36;0;32;0
WireConnection;39;0;40;0
WireConnection;30;0;39;0
WireConnection;30;1;36;0
WireConnection;61;0;60;0
WireConnection;62;0;31;0
WireConnection;62;1;61;0
WireConnection;8;0;30;0
WireConnection;52;0;39;0
WireConnection;0;2;8;0
ASEEND*/
//CHKSM=91FBD4A7ECC9A0FB04DDC28CD13B82EFD52ACF15