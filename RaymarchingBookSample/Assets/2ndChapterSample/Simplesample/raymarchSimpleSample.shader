Shader "Butadiene/raymarchSimpleSample"
{
	
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
	
			float sphere(float3 p) //球の距離関数
			{
				return length(p) - 0.5;
			}


				struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 pos : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};



			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.pos = mul(unity_ObjectToWorld,v.vertex).xyz;
				//メッシュのワールド座標を代入
				o.uv = v.uv;
				return o;
			}



			fixed4 frag(v2f i) : SV_Target
			{
				float3 ro = _WorldSpaceCameraPos;//レイのスタート位置をカメラの座標とする
				float3 rd = normalize(i.pos.xyz - ro);//メッシュのワールド座標からレイのスタート位置を引くことでレイの方向を定義
	
				float d =0;
				float t=0;
				float3 p = float3(0, 0, 0);
				for (int i = 0; i < 60; ++i) { //レイマーチングのループを実行
					p = ro + rd * t;
					d = sphere(p);
					t += d;
				}
				float4 col = float4(0,0,0,1);
				if (d > 0.01) { //レイが衝突していないと判断すれば黒に描画する
					col = float4(0, 0, 0, 1);
				}
				else {
					col = float4(1, 1, 1, 1);////レイが衝突していれば白に描画する
				}
				return col;

			}
			ENDCG
		}

	}
}