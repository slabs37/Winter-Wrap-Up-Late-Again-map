Shader "Custom/CurvedSurfaceShader"
{
    Properties
    {
        _Color ("Colour", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _FakeShadow ("Fake Shadow Power", Range(0,1)) = 0
        _Opacity ("Opacity", Range(0,1)) = 1
        _BendAmount ("_BendAmount", float) = 0
        _BendOrigin ("_BendOrigin", Vector) = (0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha 

        CGPROGRAM
        #pragma target 3.0

        #include "UnityCG.cginc"       

        struct input
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        //Physically based Standard lighting model, and enable shadows on all light types.
        #pragma surface surf Standard fullforwardshadows addshadow alpha:fade
        //Vertex needed to generate curve effect.
        #pragma vertex vert

        float _BendAmount;
        float3 _BendOrigin;

        void vert (inout appdata_full v)
        {
            float dist = distance(v.texcoord.xy, _BendOrigin);
            v.vertex.y += (dist*dist)*_BendAmount;
        }

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        half _FakeShadow;
        fixed4 _Color;
        float _Opacity;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by colour
            float shadowf = (saturate(dot(-_WorldSpaceLightPos0, IN.viewDir))+0.1)*(1-_FakeShadow);
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb * shadowf;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a*_Opacity;
        }
        ENDCG
    }
    FallBack "Diffuse"
}