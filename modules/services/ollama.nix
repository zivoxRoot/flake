{ ... }:

{
  services.ollama = {
    enable = true;

    syncModels = true;
    loadModels = [
      "qwen3:8b"
      "gemma3:4b"
    ];
  };
}
