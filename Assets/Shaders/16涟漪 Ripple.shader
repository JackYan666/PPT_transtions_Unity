Shader "Jack Shaders/16涟漪 Ripple"
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
            #define u_width  2048
            #define u_height  1024
            // float u_width = 2048;
            // float  u_height = 1024;
            // 此变换函数对纹理坐标产生偏移，以模拟折射效果
            fixed2 transform(fixed2 texCoord, fixed2 waveCenter, float radiusOffset)
            {
                fixed2 res = texCoord;
                res = res - waveCenter;
                float radius = sqrt(pow(res.x, 2.0) + pow(res.y / u_width * u_height, 2.0));
                res = res + radiusOffset * fixed2(res.x, res.y / u_width * u_height) / radius;
                res = res + waveCenter;
                return res;
            }
            
            
            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed u_ratio = _Ratio;
                fixed2 texCoord = i.uv;
                
                // 水波纹的周期
                float T = PI / 30.0;
                // 水波纹的波的个数
                float waveNum = 3.0;
                // 水波纹中心
                fixed2 waveCenter = fixed2(0.5, 0.5);
                float texR = sqrt(pow(texCoord.x - waveCenter.x, 2.0) + pow((texCoord.y - waveCenter.y) / u_width * u_height, 2.0));
                
                float radiusOffset = 0.0; // 初始化折射的偏移量，没有用真实的折射公式来计算，仅仅是根据水波纹的梯度作了偏移
                float intensityOffset = 0.0; // 初始化亮度的调整量，同样根据水波纹的梯度来修改
                // 限定波的出现范围
                if (texR > u_ratio * (sqrt(2.0) + waveNum * T) - waveNum * T && texR < u_ratio * (sqrt(2.0) + waveNum * T))
                {
                    float sinFunction = sin(texR * 2.0 * PI / T - u_ratio * 2.0 * PI / T * ((sqrt(2.0) + waveNum * T)));
                    radiusOffset = 0.02 * sinFunction;
                    intensityOffset = 0.1 * sinFunction;
                }
                // 设置混合参数，为简单的线性函数，同Shape里面的圆形
                float alpha = clamp((u_ratio * (sqrt(2.0) + waveNum * T) - texR) / (1.0 / 2.0 * T), 0.0, 1.0);
                
                fixed2 texCoordAfterTransform = transform(texCoord, waveCenter, radiusOffset);
                fixed4 texColor1 = tex2D(_MainTex, texCoordAfterTransform);
                fixed4 texColor2 = tex2D(_SecondTex, texCoordAfterTransform);
                
                fixed4 resColor = mix(texColor1, texColor2, alpha);
                resColor = resColor * (1.0 + intensityOffset);
                return resColor;
            }
            ENDCG
            
        }
    }
}
