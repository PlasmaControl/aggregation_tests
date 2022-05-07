# see e.g. https://keras.io/examples/generative/lstm_character_level_text_generation/

import h5py
import tensorflow as tf
import datetime
import numpy as np
from keras.models import Model
from keras.layers import Input
from keras.layers import LSTM, Dense

f = h5py.File('data.h5')
lookahead=1
lookback=3
step=2
T_input, a_input, b_input = [],[],[]
final_input = []
T_output = []
num_x=10
num_shots=2
for shot in range(1,num_shots):
    for t_index in range(lookback,len(f[str(shot)]['T'])-lookahead,step):
        T_input.append(np.reshape(f[str(shot)]['T'][t_index-lookback:t_index],(lookback,num_x)))
        a_input.append(np.reshape(f[str(shot)]['aDiscrete'][t_index-lookback:t_index],(lookback,1)))
        b_input.append(np.reshape(f[str(shot)]['bDiscrete'][t_index-lookback:t_index],(lookback,1)))
        T_output.append(np.reshape(f[str(shot)]['T'][t_index:t_index+lookahead],(lookahead,num_x)))
        final_input.append(np.concatenate((T_input[-1], a_input[-1], b_input[-1]),axis=-1))
T_input=np.array(T_input)
a_input=np.array(a_input)
b_input=np.array(b_input)
final_input=np.array(final_input)
T_output=np.array(T_output)

inputs1 = Input(shape=(lookback,num_x+2)) # 2 = (1 for a) + (1 for b)
lstm1 = LSTM(10)(inputs1)
model = Model(inputs=inputs1, outputs=lstm1)
model.compile(loss='mse')
model.fit(x=final_input,y=T_output)
