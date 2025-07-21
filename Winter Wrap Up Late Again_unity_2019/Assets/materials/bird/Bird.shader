Shader "Custom/Bird"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _BendAmount ("_BendAmount", float) = 0
        _BendOrigin ("_BendOrigin", Vector) = (0,0,0)
        _BendScale ("Bend Scale", float) = 1
        _BendSpeed ("Bend Speed", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha Zero

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make sure to include this for lighting
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
				float4 texcoord: TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex: POSITION;
				float4 texcoord: TEXCOORD0;
            };

            float _BendAmount;
            float _BendScale;
            float _BendSpeed;
            float3 _BendOrigin;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float dist = distance(v.texcoord.xy, _BendOrigin)*_BendScale;
                o.vertex.y += (dist*dist)*_BendAmount*sin(_Time.y*_BendSpeed);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return float4(_Color.rgb, Luminance(_Color)*0);
            }
            ENDCG
        }
         Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On ZTest LEqual
        }
    }
}