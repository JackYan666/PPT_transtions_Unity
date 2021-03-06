Shader "Jack Shaders/09揭开 Uncover"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" { }
        _SecondTex ("SecondTex", 2D) = "black" { }
        _Ratio ("Ratio", Range(0, 1)) = 0
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
            fixed _Ratio;
            float4 _MainTex_ST;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                
                fixed2 texCoord = i.uv;
                fixed4 resColor = 0;
                
                fixed R = 1 - _Ratio;
                
                if (texCoord.x >= R && texCoord.y >= R)
                    resColor = tex2D(_MainTex, fixed2(texCoord.x - R, texCoord.y - R));
                else
                    resColor = tex2D(_SecondTex, fixed2(texCoord.x, texCoord.y));
                
                return resColor ;
            }
            ENDCG
            
        }
    }
}
