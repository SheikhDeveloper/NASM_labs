void process_image_c(unsigned char *image, int width, int height, int channels) {

    for (int y = 0; y < height / 2 + 1; y++) {
        for (int x = 0; x < width; x++) {
            int mirrored_y = height - 1 - y; // Инвертируем по вертикали
            for (int c = 0; c < channels; c++) {
                // Копируем пиксель из исходного изображения в буфер с отражением
                unsigned char pixel = image[y * width * channels + x * channels + c];
                image[y * width * channels + x * channels + c] = 
                    image[mirrored_y * width * channels + x * channels + c];
                image[mirrored_y * width * channels + x * channels + c] = pixel;
            }
        }
    }

}
