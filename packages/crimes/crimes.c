#define _GNU_SOURCE

#include <freetype/freetype.h>
#include <dlfcn.h>

#include "font.h"

typedef FT_Error (*FT_New_Memory_Face_t)(FT_Library library, const FT_Byte *file_base, FT_Long file_size, FT_Long face_index, FT_Face *aface);
FT_New_Memory_Face_t FT_New_Memory_Face_real;

FT_Error FT_New_Memory_Face(FT_Library library, const FT_Byte *file_base, FT_Long file_size, FT_Long face_index, FT_Face *aface) {
    if (!FT_New_Memory_Face_real) {
        FT_New_Memory_Face_real = dlsym(RTLD_NEXT, "FT_New_Memory_Face");
    }

    return FT_New_Memory_Face_real(library, font, font_len, 0, aface);
}

FT_Error FT_Open_Face(FT_Library library, const FT_Open_Args* args, FT_Long face_index, FT_Face *aface) {
    return FT_New_Memory_Face(library, NULL, 0, face_index, aface);
}

FT_Error FT_New_Face(FT_Library library, const char* pathname, FT_Long face_index, FT_Face *aface) {
    return FT_New_Memory_Face(library, NULL, 0, face_index, aface);
}
