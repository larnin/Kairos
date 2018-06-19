using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class ReplacementShaderEffect : MonoBehaviour {

	public Shader OutlineShader;
	public Shader BlurShader;

	public int iterations = 3;
	public float blurSpread = 0.6f;

	private static RenderTexture PrePass;
	private static RenderTexture Blurred;

	private Material _blurMat;

    void OnEnable()
	{
        PrePass = new RenderTexture (Mathf.Max(Screen.width, 4), Mathf.Max(Screen.height, 4), 24);
		PrePass.antiAliasing = QualitySettings.antiAliasing;
        Blurred = new RenderTexture (Mathf.Max(Screen.width, 4), Mathf.Max(Screen.height, 4), 0);

		var camera = GetComponent<Camera> ();
		camera.targetTexture = PrePass;
		camera.SetReplacementShader (OutlineShader, "TakeFocus");
		Shader.SetGlobalTexture("_GlowPrepassTex", PrePass);
		Shader.SetGlobalTexture("_GlowBlurredTex", Blurred);

		_blurMat = new Material (BlurShader);
		_blurMat.SetVector ("_BlurSize", new Vector2 (Blurred.texelSize.x * 1.5f, Blurred.texelSize.y * 1.5f));
	}

	// Performs one blur iteration.
	public void FourTapCone (RenderTexture source, RenderTexture dest, int iteration)
	{
		float off = 0.1f + iteration*blurSpread;
		Graphics.BlitMultiTap (source, dest, _blurMat,
			new Vector2(-off, -off),
			new Vector2(-off,  off),
			new Vector2( off,  off),
			new Vector2( off, -off)
		);
	}

	// Downsamples the texture to a quarter resolution.
	private void DownSample4x (RenderTexture source, RenderTexture dest)
	{
		float off = 1.0f;
		Graphics.BlitMultiTap (source, dest, _blurMat,
			new Vector2(-off, -off),
			new Vector2(-off,  off),
			new Vector2( off,  off),
			new Vector2( off, -off)
		);
	}

	void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
		Graphics.Blit(src, dst);

		Graphics.SetRenderTarget(Blurred);
		GL.Clear(false, true, Color.clear);

		Graphics.Blit(src, Blurred);

		int rtW = src.width/4;
		int rtH = src.height/4;
		RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);

		// Copy source to the 4x4 smaller texture.
		DownSample4x (src, buffer);

		// Blur the small texture
		for(int i = 0; i < iterations; i++)
		{
			RenderTexture buffer2 = RenderTexture.GetTemporary(rtW, rtH, 0);
			FourTapCone (buffer, buffer2, i);
			RenderTexture.ReleaseTemporary(buffer);
			buffer = buffer2;
		}
		Graphics.Blit(buffer, Blurred);

		RenderTexture.ReleaseTemporary(buffer);
	}
}
