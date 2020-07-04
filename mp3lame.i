
%module mp3lame

%{
#define SWIG_FILE_WITH_INIT
#include "lame/lame.h"
%}

%inline %{
typedef struct LameDecoder {
    hip_t gfp;
} LameDecoder;

typedef struct LameEncoder {
    lame_t lame;
} LameEncoder;
%}

%extend LameDecoder {
    %typemap(in) unsigned char* {
      if (!PyByteArray_Check($input)) {
        SWIG_exception_fail(SWIG_TypeError, "in method '" "$symname" "', argument "
                           "$argnum"" of type '" "$type""'");
      }
      $1 = (unsigned char*) PyByteArray_AsString($input);
    }

    LameDecoder(){
        LameDecoder * x = malloc(sizeof(LameDecoder));
        x->gfp = hip_decode_init();
        return x;
    }

    ~LameDecoder(){
        hip_decode_exit($self->gfp);
        free($self);
    }

    int decode_frame(unsigned char*  mp3buf
                   , size_t          begin
                   , size_t          len
                   , size_t          total_read
                   , unsigned char * pcm_l
                   , unsigned char * pcm_r
                   )
    {
        short * pcm_l_begin = &(((short *) pcm_l)[total_read]);
        short * pcm_r_begin = &(((short *) pcm_r)[total_read]);
        unsigned char * mp3_begin = &(mp3buf[begin]);
        return hip_decode1($self->gfp, mp3_begin, len,
            pcm_l_begin, pcm_r_begin);
    }
}

%extend LameEncoder {
    
    /*
     * Typemap needs to be declared inside this block because (???)
     */
    %typemap(in) unsigned char* {
      if (!PyByteArray_Check($input)) {
        SWIG_exception_fail(SWIG_TypeError, "in method '" "$symname" "', argument "
                           "$argnum"" of type '" "$type""'");
      }
      $1 = (unsigned char*) PyByteArray_AsString($input);
    }

    LameEncoder(int sample_rate, int bit_rate, int quality, int num_channels){
        LameEncoder * x = malloc(sizeof(LameEncoder));
        x->lame = lame_init();
        lame_set_in_samplerate(x->lame, sample_rate);
        lame_set_VBR(x->lame, bit_rate);
        lame_set_VBR_q(x->lame, quality);
        lame_set_num_channels(x->lame, num_channels);
        lame_init_params(x->lame);
        return x;
    }

    ~LameEncoder()
    {
      lame_close($self->lame);
      free($self);
    }

    int flush(unsigned char * mp3_buffer
            , size_t          total_read)
    {
      unsigned char * mp3_begin = &(mp3_buffer[total_read]);
      return lame_encode_flush($self->lame, mp3_begin, 0);
    }

    int encode(unsigned char *         pcm_l
             , unsigned char *         pcm_r
             , size_t          begin
             , int             num_samples
             , unsigned char * mp3_buffer
             , size_t          total_read
             )
    {
      short * pcm_l_begin = &(((short *) pcm_l)[begin]);
      short * pcm_r_begin = &(((short *) pcm_r)[begin]);
      unsigned char * mp3_begin = &(mp3_buffer[total_read]);
      return lame_encode_buffer($self->lame, pcm_l_begin, pcm_r_begin, num_samples, mp3_begin, 0);
    }
}