Shader "Custom/AtmosphereBend"
{
    Properties
    {
        _Color ("Colour", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Emissive ("Emissiveness", float) = 1
        _Opacity ("Opacity", float) = 1
        _BendAmount ("_BendAmount", float) = 0
        _BendOrigin ("_BendOrigin", Vector) = (0,0,0)
        _FresnelPOW ("Fresnel Power", float) = 1
        _Fresnel2Pow ("Fresnel2 Power", float) = 1
        _Fresnel2Mult ("Fresnel2 Multiplier", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend One One
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
        float _FresnelPOW;
        float _Fresnel2Pow;
        float _Fresnel2Mult;

        void vert (inout appdata_full v)
        {
            float dist = distance(v.texcoord.xy, _BendOrigin);
            v.vertex.y += (dist*dist)*_BendAmount;
        }

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Opacity;
        float _Emissive;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by colour
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;

            float fresnellight = dot(-_WorldSpaceLightPos0, IN.viewDir);
            float fresnelnorm = dot(IN.worldNormal, IN.viewDir);
            float fresnel = saturate(lerp(1, fresnellight, fresnelnorm));
            fresnel = pow(fresnel, _FresnelPOW);

            float fresnel2 = dot(IN.worldNormal, IN.viewDir);
            fresnel2 = saturate(fresnel2);
            fresnel2 = pow(fresnel2, _Fresnel2Pow)*_Fresnel2Mult;

            float fresnel3 = dot(IN.worldNormal, IN.viewDir);
            fresnel3 = pow(saturate(fresnel3),5);

            o.Alpha = c.a*_Opacity*fresnel*fresnel2;
            o.Emission = _Color*_Emissive*fresnel*fresnel2;
        }
        ENDCG
    }
    FallBack "Diffuse"
}