//
//  iAndersChessApp-Bridging-Header.h
//  iAndersChessApp
//
//  Created by iAnders Chess App
//

#ifndef iAndersChessApp_Bridging_Header_h
#define iAndersChessApp_Bridging_Header_h

// C++ Headers for Stockfish integration
#ifdef __cplusplus
extern "C" {
#endif

// Stockfish engine functions
void stockfish_init(void);
void stockfish_cleanup(void);
const char* stockfish_get_best_move(const char* fen, int depth, double time);
double stockfish_evaluate_position(const char* fen);
void stockfish_set_option(const char* name, const char* value);

#ifdef __cplusplus
}
#endif

#endif /* iAndersChessApp_Bridging_Header_h */