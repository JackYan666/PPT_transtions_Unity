Shader "Jack Shaders/05Reveal 显示"
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
            
            
            fixed2 transform(fixed2 texcoord, fixed2 scaleCenter, fixed2 scaleRatio)
            {
                fixed2 res = texcoord;
                // shader 里面的所有 texcoord 的变换操作均与实际坐标点相反
                res = res - scaleCenter;// 图片从缩放中心点移动到原点
                res = res / scaleRatio;// 执行缩放
                res = res + scaleCenter;// 图片从原点移动到缩放中心点
                return res;
            }
            fixed4 frag(v2f i): SV_Target
            {
                fixed4 resColor = 0;
                
                float w = 1.0;
                if (_Ratio <= 0.5)
                {
                    float ratioNor = _Ratio * 2.0;
                    fixed2 scaleRatio = (1.0 + 0.1 * ratioNor);
                    fixed4 texColor1 = tex2D(_MainTex, transform(i.uv, fixed2(0.75, 0.5), scaleRatio));
                    float alpha = clamp(-1.0 / w * i.uv.x + (1.0 + w) / w * (1.0 - ratioNor), 0.0, 1.0);
                    resColor = mix((fixed4)0.0, texColor1, alpha);
                }
                else
                {
                    float ratioNor = (_Ratio - 0.5) * 2.0;
                    fixed2 scaleRatio = (1.0 + 0.1 * (1.0 - ratioNor));
                    fixed4 texColor2 = tex2D(_SecondTex, transform(i.uv, fixed2(0.25, 0.5), scaleRatio));
                    float alpha = 1.0 - clamp(-1.0 / w * i.uv.x + (1.0 + w) / w * ratioNor, 0.0, 1.0);
                    resColor = mix(texColor2, (fixed4)0.0, alpha);
                }
                
                return resColor ;
            }
            ENDCG
            
        }
    }
}
