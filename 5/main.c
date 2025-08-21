#include <stdio.h>
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

extern void process_image_asm(unsigned char *image, int width, int height, int channels);

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Использование: %s <входной файл> <выходной файл>\n", argv[0]);
        return 1;
    }

    // Загрузка изображения
    int width, height, channels;
    unsigned char *image = stbi_load(argv[1], &width, &height, &channels, 0);
    if (!image) {
        fprintf(stderr, "Ошибка загрузки изображения\n");
        return 1;
    }

    // print_array(image, width, height, channels);
    // Обработка изображения (замените на process_image_asm для ассемблера)
    process_image_c(image, width, height, channels);
    //process_image_asm(image, width, height, channels);

    //printf("\n\n");
    //print_array(image, width, height, channels);
    // Сохранение результата
    if (!stbi_write_jpg(argv[2], width, height, channels, image, width * channels)) {
        fprintf(stderr, "Ошибка сохранения изображения\n");
    }

    stbi_image_free(image);
    return 0;
}

// Функция обработки на C: умножение матриц 3x3 (усреднение)

