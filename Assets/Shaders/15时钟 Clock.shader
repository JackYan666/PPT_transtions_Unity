Shader "Jack Shaders/15时钟 Clock"
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
            
            
            #define PI 3.1415926
            // 用此函数来计算角度，以处理四个象限的不同情况
            float atan2(float a, float b)
            {
                if (a > 0 && b > 0)
                    return atan(b / a);
                if(a < 0 && b > 0)
                    return atan(-a / b) + PI / 2.0;
                if(a < 0 && b < 0)
                    return atan(b / a) + PI;
                //if(a > 0 && b < 0)
                    return atan(a / - b) + PI * 3.0 / 2.0;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed4 t1 = tex2D(_MainTex, i.uv);
                fixed4 t2 = tex2D(_SecondTex, i.uv);
                float w = 0.2;
                float theta = atan2(i.uv.y - 0.5, i.uv.x - 0.5);
                // 此处可参考 Wips擦除 效果里面的实现
                float alpha = clamp(1 / w * theta + 1.0 + _Ratio * (-2.0 * PI / w - 1.0), 0.0, 1.0);
                return mix(t2, t1, alpha) ;
            }
            ENDCG
            
        }
    }
}
