#!/bin/bash

# 🔐 API-ключ Mistral
if [ -z "$MISTRAL_API_KEY" ]; then
    echo "❌ Ошибка: Переменная окружения MISTRAL_API_KEY не установлена." >&2
    exit 1
fi

# Проверка зависимостей
for cmd in gdbus tesseract wl-copy wl-paste curl jq; do
    if ! command -v "$cmd" >/dev/null; then
        echo "❌ Ошибка: Не найдена команда $cmd" >&2
        exit 1
    fi
done

# Получаем скриншот области через порталы и копируем в буфер
echo "📸 Захватываем область экрана..."
gdbus call --session \
    --dest org.freedesktop.portal.Desktop \
    --object-path /org/freedesktop/portal/desktop \
    --method org.freedesktop.portal.Screenshot.Screenshot \
    "{}" "{'interactive': <true>, 'handle_token': <'screenshot'>}" >/dev/null

# Ждем появления изображения в буфере (макс 5 сек)
timeout=5
while ! wl-paste --list-types | grep -q "image/png"; do
    sleep 0.1
    timeout=$((timeout - 1))
    [ $timeout -le 0 ] && {
        echo "❌ Таймаут ожидания скриншота" >&2
        exit 1
    }
done

# Извлекаем изображение из буфера
echo "🔍 Распознаем текст..."
TEXT=$(wl-paste --type image/png | tesseract stdin stdout -l rus+eng 2>/dev/null)

if [ -z "$TEXT" ]; then
    echo "❌ Не удалось распознать текст" >&2
    exit 1
fi

echo -e "\n📄 Распознанный текст:\n$TEXT\n" | tee >(wl-copy)
echo "📋 Текст скопирован в буфер"

# Контекст для Mistral AI
CONTEXT="Ты - эксперт по анализу текста. Отвечай ТОЛЬКО номером правильного ответа, без каких-либо пояснений, рассуждений или дополнительного текста. Если вопрос не содержит вариантов ответа, верни '0'."

# Отправка в Mistral AI
echo "🌐 Отправляем запрос..."
RESPONSE=$(curl -s -X POST https://api.mistral.ai/v1/chat/completions \
    -H "Authorization: Bearer $MISTRAL_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
        --arg model "mistral-large-latest" \
        --arg context "$CONTEXT" \
        --arg text "$TEXT" \
        '{
            model: $model,
            messages: [
                {"role": "system", "content": $context},
                {"role": "user", "content": $text}
            ],
            temperature: 0.1
        }')")

# Вывод ответа (только номер)
ANSWER=$(jq -r '.choices[0].message.content' <<<"$RESPONSE" | grep -oE '[0-9]+' || echo "0")
echo -e "\n🔢 Ответ от AI: $ANSWER"
