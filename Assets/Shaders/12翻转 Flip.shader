Shader "Jack Shaders/12翻转 Flip"
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
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = (v.uv);
                return o;
            }
            
            #define PI 3.1415926
            fixed2 transform(fixed2 texCoord, float theta, float zOffset)
            {
                fixed2 res = texCoord - 0.5;    // 从 (0.5,0.5) 移动到 (0,0)
                // 执行旋转和投影（投影本质上是剪切）
                res.x = res.x / cos(theta);
                res.y = res.y / (1.0 - res.x * sin(theta));
                res.x = res.x / (1.0 - res.x * sin(theta));
                res = res * (1.0 + zOffset);    // 执行 z 方向的位移，经过投影后，整体视作缩放
                res = res + 0.5;    // 从 (0,0) 移动到 (0.5,0.5)
                return res;
            }            
            
            fixed4 frag(v2f i): SV_Target
            {
                float u_ratio = _Ratio;
                // 图片在z方向上的偏移量
                float zOffset = 0.2 - abs(0.4 * u_ratio - 0.2);
                fixed2 texCoordAfterTransform = transform(i.uv, u_ratio * PI, zOffset*3);
                fixed4 resColor = fixed4(u_ratio, 0.0, 0.0, 1.0);
                fixed4 texColor1 = 0.0;
                if (UVRange0_1(texCoordAfterTransform) > 0.1)
                    texColor1 = tex2D(_MainTex, texCoordAfterTransform);
                fixed4 texColor2 = 0.0;
                if(UVRange0_1(texCoordAfterTransform) > 0.1)
                    texColor2 = tex2D(_SecondTex, fixed2(1.0 - texCoordAfterTransform.x, texCoordAfterTransform.y));
                if(u_ratio <= 0.5)
                    return texColor1;
                else
                return  texColor2;
            }
            ENDCG
            
        }
    }
}
