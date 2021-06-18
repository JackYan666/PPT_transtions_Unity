Shader "Jack Shaders/28梳理 Comb"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" { }
        _SecondTex ("SecondTex", 2D) = "black" { }
        u_ratio ("Ratio", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Assets\Shaders\Tools\Tools.cginc"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
            };
            
            sampler2D _MainTex;
            sampler2D _SecondTex;
            fixed u_ratio;
            float4 _MainTex_ST;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            //#define u_width 2000
            //#define u_height 1125
            //#define PI 3.1415926
            
            
            fixed4 frag(v2f i): SV_Target
            {
                fixed2 texCoord = i.uv;
                fixed4 resColor = fixed4(u_ratio, 0.0, 0.0, 1.0);
                float halfCombNum = 3.0;
                float delay = floor(texCoord.y * halfCombNum * 2.0) / halfCombNum * 0.25; // 0-0.5
                float Ry = floor(frac(texCoord.y * halfCombNum) * 2.0);// 0-1-0-1-0-1
                float ratio = clamp(u_ratio * 2.0 - delay * 2.0, 0.0, 1.0);
                if (1.0 - Ry - ratio + (2.0 * Ry - 1.0) * texCoord.x > 0.0)
                    resColor = tex2D(_MainTex, fixed2(texCoord.x + (1.0 - 2.0 * Ry) * ratio, texCoord.y));
                else
                resColor = tex2D(_SecondTex, fixed2(texCoord.x, texCoord.y));

                
                return resColor;
            }
            ENDCG
            
        }
    }
}
