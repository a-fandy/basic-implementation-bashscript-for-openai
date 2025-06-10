# README

## chatgpt.sh

`chatgpt.sh` is a Bash script designed to interact with the OpenAI API using specified parameters. It facilitates chat interactions with a chosen model and supports different types of inputs, including text and files.

### Prerequisites

Before using `chatgpt.sh`, ensure the following prerequisites are met:

- **OpenAI API Key:** You must have a valid OpenAI API Key set as an environment variable (`OPENAI_API_KEY`).
- **JSON Processor:** The `jq` command-line tool (a lightweight and flexible command-line JSON processor) must be installed.
- **Internet Connectivity:** Ensure your environment has access to the internet to communicate with the OpenAI API.

### Installation of Prerequisites

1. **jq Installation:** 
   - On macOS:   
     ```bash
     brew install jq
     ```
   - On Ubuntu/Linux:
     ```bash
     sudo apt-get install jq
     ```
   - For Windows, `jq` can be downloaded from the [official page](https://stedolan.github.io/jq/download/) and added to the system path.

### Usage

#### Basic Command
```bash
./chatgpt.sh -p "Your message here" [-t "Type"] [-m "Model"] [-s "User Session"] [-f "file upload"] [-a "assistant"]
```
#### Creating an Alias
To make running the script easier, you can create an alias in your shell configuration file (e.g., `.bashrc`, `.bash_profile`, or `.zshrc`). Here’s how:

1. Open your shell configuration file:
   ```bash
   nano ~/.bashrc        # For bash users
   nano ~/.bash_profile  # For bash profile users
   nano ~/.zshrc         # For zsh users
   ```

2. Add the following line to create an alias for `chatgpt.sh`:
   ```bash
   alias chatgpt='/path/to/chatgpt.sh'
   ```

   Replace `/path/to/chatgpt.sh` with the actual path to the script file.

3. Save the file and exit the editor.

4. Apply the changes to your current session:
   ```bash
   source ~/.bashrc        # For bash users
   source ~/.bash_profile  # For bash profile users
   source ~/.zshrc         # For zsh users
   ```

#### Using the Alias
Once the alias is set up, you can run the script with:
```bash
chatgpt -p "Your message here" [-t "Type"] [-m "Model"] [-s "User Session"] [-f "file upload"] [-a "assistant"]
```

#### Options:
- `-p`: **(Required)** The primary message or prompt you wish to send to OpenAI.
- `-t`: **(Optional)** The type of input; defaults to `1` (text).
  - `1`: Text-only interaction.
  - `2`: Text with file upload.
  - `3`: Text with base64-encoded image (JPEG expected).
- `-m`: **(Optional)** The model to use, default is `gpt-4o`.
- `-s`: **(Optional)** User session identifier. Different sessions use different history files.
- `-f`: **(Optional)** The file path for additional content (used with types `2` and `3`).
- `-a`: **(Optional)** Defines the role or initial behavior of the assistant, defaulting to "You are a helpful assistant."

### Features

- **Session Management**: Saves conversation history in JSON files, allowing session continuity.
- **Customizable Interactions**: Supports custom user prompts and assistant roles.
- **Prompt Augmentation**: Can augment prompts with file content or images by encoding them in base64.

### Examples

1. **Basic Text Interaction:**
   ```bash
   ./chatgpt.sh -p "Tell me a joke."
   ```

2. **Interaction with a Specific Model:**
   ```bash
   ./chatgpt.sh -p "What's the weather like?" -m "gpt-3.5-turbo"
   ```

3. **Using a File with Additional Content:**
   ```bash
   ./chatgpt.sh -p "Analyze this data" -t 2 -f "data.txt"
   ```

4. **Using Image Data:**
   ```bash
   ./chatgpt.sh -p "Generate a caption for this image" -t 3 -f "image.jpg"
   ```

5. **Session-Based Interaction**:
   ```bash
   ./chatgpt.sh -p "What did we talk about last time?" -s "session1"
   ```
   This example initiates a chat using a specific session file, allowing you to maintain continuity in the conversation across different runs.

### Notes

- Ensure your `OPENAI_API_KEY` environment variable is set correctly to avoid authentication errors.
- The current directory should have write permissions to create and update session history files.

### Troubleshooting

- **`Error: OPENAI_API_KEY is not set.`**
  Ensure you export your API key before running the script:
  ```bash
  export OPENAI_API_KEY='your-api-key'
  ```

- **Invalid Option Errors:** Ensure that options are provided with their corresponding values as shown in the usage examples.

### Future Improvements

- Implement error handling for API response failures.
- Add support for more file types and multi-file uploads.
- Integrate more sophisticated argument validation and user feedback.

### License

This script is available under the [MIT License](./LICENSE).

---