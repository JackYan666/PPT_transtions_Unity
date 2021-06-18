Shader "Jack Shaders/29缩放 Zoom"
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
            fixed2 transform(fixed2 texCoord, float zOffset)
            {
                fixed2 coord = texCoord - fixed2(0.5, 0.5);
                coord = coord * (1 + zOffset); // zOffset 此处指z方向的偏移，实际上指代指缩放因子
                coord = coord + fixed2(0.5, 0.5);
                return coord;
            }
            
            
            fixed4 frag(v2f i): SV_Target
            {
                fixed2 texCoord = i.uv;
                float zOffset1 = -0.5 * u_ratio;// zOffset从 0 -> -0.5，类似缩放因子从 1 -> 1.5
                fixed2 coord1 = transform(texCoord, zOffset1);
                fixed4 texColor1 = tex2D(_MainTex, coord1);
                float zOffset2 = 0.5 * (1.0 - u_ratio);// zOffset从 0.5 -> 0，类似缩放因子从 0.5 -> 1
                fixed2 coord2 = transform(texCoord, zOffset2);
                fixed4 texColor2 = 0.0;
                if (UVRange0_1(coord2) > 0.1)
                    texColor2 = tex2D(_SecondTex, coord2);
                
                return mix(texColor1, texColor2, u_ratio);
            }
            ENDCG
            
        }
    }
}
