Shader "Jack Shaders/32翻页 PageTurn"
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
            #define PI 3.1415926
            
            fixed2 transform(fixed2 texCoord, float theta)
            {
                fixed2 res = texCoord - fixed2(0.5, 0.5);
                // 执行旋转和投影（投影本质上是剪切）
                res.x = res.x / cos(theta);
                res.y = res.y / (1.0 - res.x * sin(theta));
                res.x = res.x / (1.0 - res.x * sin(theta));
                res = res + fixed2(0.5, 0.5);
                return res;
            }

            
            fixed4 frag(v2f i): SV_Target
            {
                fixed2 texCoord = i.uv;
                // 图片在z方向上的偏移量
                fixed2 texCoordAfterTransform = transform(texCoord, -u_ratio * PI);
                fixed4 resColor=0;
                
                if (u_ratio < 0.5)
                {
                    if(texCoord.x < 0.5)
                        resColor = tex2D(_MainTex, texCoord);
                    else
                    {
                        if(texCoordAfterTransform.x > 1.0 || texCoordAfterTransform.x < 0.0 || texCoordAfterTransform.y < 0.0 || texCoordAfterTransform.y > 1.0)
                            resColor = tex2D(_SecondTex, texCoord);
                        else
                        resColor = tex2D(_MainTex, texCoordAfterTransform) * (1.0 - u_ratio);
                    }
                }
                else
                {
                    if(texCoord.x >= 0.5)
                        resColor = tex2D(_SecondTex, texCoord);
                    else
                    {
                        if(texCoordAfterTransform.x > 1.0 || texCoordAfterTransform.x < 0.0 || texCoordAfterTransform.y < 0.0 || texCoordAfterTransform.y > 1.0)
                            resColor = tex2D(_MainTex, texCoord);
                        else
                        resColor = tex2D(_SecondTex, fixed2(1.0 - texCoordAfterTransform.x, texCoordAfterTransform.y)) * (u_ratio);
                    }
                }
                
                return resColor;
            }
            ENDCG
            
        }
    }
}
