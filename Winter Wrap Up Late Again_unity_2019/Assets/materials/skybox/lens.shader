Shader "Custom/LensflareBroken"
{
    Properties
    {
        _NoiseTex    ("Noise Texture",     2D)   = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend One OneMinusSrcAlpha
        ZWrite Off
        ZTest Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature USE_DEPTH

            #include "UnityCG.cginc"
            #include "Assets/VivifyTemplate/Utilities/Shader Functions/Math.cginc"
            #include "Assets/VivifyTemplate/Utilities/Shader Functions/Noise.cginc"

            UNITY_DECLARE_SCREENSPACE_TEXTURE(_MainTex);

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata_full v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, v2f o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                return o;
            }

            sampler2D _NoiseTex;
            float4   _NoiseTex_TexelSize;

            float3 getScreenCol(float2 uv)
            {
                return UNITY_SAMPLE_SCREENSPACE_TEXTURE(_MainTex, UnityStereoTransformScreenSpaceTex(uv));
            }

            float noise2d(float2 uv)
            {
                return tex2D(_NoiseTex, uv * _NoiseTex_TexelSize.xy).r;
            }

            float3 lensflare(float2 uv, float2 pos)
            {
                float2 main = uv-pos;
                float2 uvd = uv*(length(uv));
                
                float ang = atan2(main.y, main.x);
                float dist=length(main); dist = pow(dist,.1);
                float n = noise2d(float2(ang*16.0, dist*32.0));
                
                float f0 = 1.0/(length(uv-pos)*16.0+1.0);
                
                f0 = f0+f0 * (sin((ang + n*2.0)*12.0)*0.1 + dist*0.1 + 0.8);

                float f2 = max(1.0/(1.0+32.0*pow(length(uvd+0.8*pos),2.0)),.0)*00.25;
                float f22 = max(1.0/(1.0+32.0*pow(length(uvd+0.85*pos),2.0)),.0)*00.23;
                float f23 = max(1.0/(1.0+32.0*pow(length(uvd+0.9*pos),2.0)),.0)*00.21;
                
                float2 uvx = lerp(uv,uvd,-0.5);
                
                float f4 = max(0.01-pow(length(uvx+0.4*pos),2.4),.0)*6.0;
                float f42 = max(0.01-pow(length(uvx+0.45*pos),2.4),.0)*5.0;
                float f43 = max(0.01-pow(length(uvx+0.5*pos),2.4),.0)*3.0;
                
                uvx = lerp(uv,uvd,-.4);
                
                float f5 = max(0.01-pow(length(uvx+0.2*pos),5.5),.0)*2.0;
                float f52 = max(0.01-pow(length(uvx+0.4*pos),5.5),.0)*2.0;
                float f53 = max(0.01-pow(length(uvx+0.6*pos),5.5),.0)*2.0;
                
                uvx = lerp(uv,uvd,-0.5);
                
                float f6 = max(0.01-pow(length(uvx-0.3*pos),1.6),.0)*6.0;
                float f62 = max(0.01-pow(length(uvx-0.325*pos),1.6),.0)*3.0;
                float f63 = max(0.01-pow(length(uvx-0.35*pos),1.6),.0)*5.0;
                
                float3 c = float3(0,0,0);
                
                c.r+=f2+f4+f5+f6; c.g+=f22+f42+f52+f62; c.b+=f23+f43+f53+f63;
                c+=float3(f0.xxx);
                
                return c;

            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);


                return float4(lensflare(getScreenCol(i.uv),i.uv), 0);
            }
            ENDCG
        }
    }
}
