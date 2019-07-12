from kipoi.model import BaseModel
from keras.models import load_model
from keras.layers import Layer
from keras import backend as K
import tensorflow as tf
import numpy as np

class FrameSliceLayer(Layer):
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)    

    def build(self, input_shape):
        super().build(input_shape)  # Be sure to call this at the end
    
    def call(self, x):
        shape = K.shape(x)
        x = K.reverse(x, axes=1) # reverse, so that frameness is related to fixed point
        frame_1 = tf.gather(x, K.arange(start=0, stop=shape[1], step=3), axis=1)
        frame_2 = tf.gather(x, K.arange(start=1, stop=shape[1], step=3), axis=1)
        frame_3 = tf.gather(x, K.arange(start=2, stop=shape[1], step=3), axis=1)
        return [frame_1, frame_2, frame_3]
    
    def compute_output_shape(self, input_shape):
        return [(input_shape[0], None, input_shape[2]),(input_shape[0], None, input_shape[2]),(input_shape[0], None, input_shape[2])]

class VariableLengthInputKerasModelWithVariantEffect(BaseModel):
    
        def __init__(self, weights):
            self.nuc_dict = {'A':[1.0,0.0,0.0,0.0],'C':[0.0,1.0,0.0,0.0],'G':[0.0,0.0,1.0,0.0], 
                             'U':[0.0,0.0,0.0,1.0], 'T':[0.0,0.0,0.0,1.0], 
                             'N':[0.0,0.0,0.0,0.0], 'X':[1/4,1/4,1/4,1/4]}
            self.weights = weights
            self.model = load_model(weights, custom_objects={'FrameSliceLayer': FrameSliceLayer})
        
        def encode_seq(self, seq, max_len):
            # Add padding:
            if max_len == 0:
                padding_needed = 0
            else:
                padding_needed = max_len - len(seq)
            seq = "N"*padding_needed + seq
            # One hot encode
            try:
                one_hot = np.array([self.nuc_dict[x] for x in seq]) # get stacked on top of each other
            except KeyError as e:
                raise ValueError('Cant one-hot encode unkown base: {}. \ 
                                 Possible cause: a variant in the vcf file is defined by a tag (<..>). \
                                 If so, please filter'.format(str(e)))
            return one_hot
        
        def build_indicator(self, experiment, n):
            indicator = [0,0,0,0,0]
            indicator[experiment] = 1
            return np.repeat(np.array(indicator)[np.newaxis,:], n, axis=0)
        
        def encode_input(self, input_sequences):
            max_len = len(max(input_sequences, key=len))
            one_hot = np.stack([self.encode_seq(seq, max_len) for seq in input_sequences],  axis = 0)
            indicator = self.build_indicator(0, one_hot.shape[0])
            return [one_hot, indicator]
       
        def predict_on_batch_inner(self, inputs):
            # One Hot Encode and attach indicator parameter
            encoded_inputs = self.encode_input(inputs)
            # Predict
            predict = self.model.predict_on_batch(encoded_inputs)
            return predict
        
        def predict_on_batch(self, inputs):
            if inputs.shape == (2,):
                inputs = inputs[np.newaxis, :]
            pred_ref = self.predict_on_batch_inner(inputs[:,0]).reshape(-1)
            pred_variant = self.predict_on_batch_inner(inputs[:,1]).reshape(-1)
            mrl_fold_change = np.log2(pred_variant/pred_ref)
            return mrl_fold_change