# Screenshot OCR to Mistral AI
Tested on Ubuntu 24.10,GNOME Shell 47.0 Wayland

This is a Bash script that allows you to capture a selected area of your screen, perform OCR (Optical Character Recognition) on the screenshot to extract text (supports Russian and English), and then send the extracted text to the Mistral AI API for analysis. The AI responds with a numeric answer based on the recognized text.(The behavior can be changed by replacing the CONTEXT setting text in the HTTP request)

## Features

- Interactive screen area capture using the desktop portal
- Text extraction from the screenshot using Tesseract OCR
- Supports Russian and English languages for OCR
- Sends extracted text to Mistral AI for answer prediction(You can get API key for FREE)
- Outputs text to consolefrom the AI response
- Copies recognized text to clipboard for easy use

## Prerequisites

Make sure the following commands/tools are installed and available in your system:

- `gdbus`
- `tesseract` (with Russian and English language data installed)
- `wl-clipboard` (Wayland clipboard)
- `curl`
- `jq`

## Setup

1. Obtain an API key from [Mistral AI](https://mistral.ai).

2. Set the API key as an environment variable in your shell:

```bash
export MISTRAL_API_KEY="your_api_key_here"
```

## Usage

There are two scripts available:

- `smart_screenshot_analyzer_out_number.sh`: Sends the recognized text to Mistral AI and outputs a numeric answer.
- `smart_screenshot_analyzer_out_text.sh`: Sends the recognized text to Mistral AI and outputs the textual answer.

Run the desired script:

```bash
./smart_screenshot_analyzer_out_number.sh
```

or

```bash
./smart_screenshot_analyzer_out_text.sh
```

The script will:

1. Prompt you to select an area of your screen to capture.
2. Perform OCR on the captured image to extract text.
3. Display the recognized text and copy it to your clipboard.
4. Send the text to Mistral AI and output the numeric answer returned by the AI.

## Notes

- The script has a timeout of 5 seconds waiting for the screenshot to appear in the clipboard.
- Make sure you are running this in a Wayland session as it uses Wayland clipboard utilities.

