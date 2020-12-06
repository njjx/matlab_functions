# -*- coding: utf-8 -*-
"""
Created on Fri Apr 26 13:35:30 2019

@author: xji
"""

import numpy as np


class dataset_obj(object):
    
    #The input data is a vector, the order is 1st image, 2nd image, 3rd image, ...
    #The input data do not have to be reshaped. 
    #The data will be automatically reshaped in the initialization process.
    #The x dimension and the y dimension need to be specified in the input data. 
    #The shape of the data is (?, dim_z,dim_y,dim_x)
    #dim_x is put at the end of the shape is because python first read the last index of a tuple
    def __init__ (self,data,img_dim_x,img_dim_y):
        self._num_examples=round(img_dim_x*img_dim_y)
        #number of samples is the same with the pixels in one image
        #this is because later we will segement the image into patches 
        #instead of using the whole image as the training sample
        
        self._img_dim_x=img_dim_x
        self._img_dim_y=img_dim_y
        data=np.reshape(data,(-1))
        self._img_dim_z=round(data.shape[0]/self._num_examples)
        
        self._data=np.reshape(data,(1,self._img_dim_z,img_dim_y,img_dim_x))
        
        self._epochs_completed=0
        self._index_in_epoch=0
        self._perm=np.arange( self._num_examples)

    @property
    def num_examples(self):
            return self._num_examples

    @property
    def epochs_completed(self):
            return self._epochs_completed

    #This function add new group of data to the object
    #The added data should have the same dimension with the previous data
    #The number of group of data is in the first dimension of the data tuple
    def add_data(self,data,img_dim_x,img_dim_y):
        data=np.reshape(data,(-1))
        img_dim_z=round(data.shape[0]/img_dim_x/img_dim_y)
        if self._img_dim_x!=img_dim_x or self._img_dim_y!=img_dim_y or self._img_dim_z!=img_dim_z:
            print("Error image dimension!")
        else:
            self._num_examples+=round(img_dim_x*img_dim_y)
            data_reshape=np.reshape(data,(1,self._img_dim_z,img_dim_y,img_dim_x))
            self._data=np.concatenate((self._data,data_reshape),axis=0)
            self._perm=np.arange(self._num_examples)

    def shuffle_data(self):
        np.random.shuffle(self._perm)
    
    #change the 3d index to 1d index
    def one_d_index_to_3d_index(self, index):
        data_idx=index//(self._img_dim_x*self._img_dim_y)
        idx_in_image=index%(self._img_dim_x*self._img_dim_y)
        y_idx=idx_in_image//self._img_dim_x
        x_idx=idx_in_image%self._img_dim_x
        return data_idx, y_idx, x_idx
    
    #this function judges whether the index reaches the boundary of the 2D image
    #the patch_size can be either even or odd
    def judge_whether_index_reach_boundary(self,index, patch_size_x,patch_size_y):
        patch_size_x_half=patch_size_x//2;
        patch_size_y_half=patch_size_y//2;
        if patch_size_x%2==1:
            bod_x_2=self._img_dim_x-patch_size_x_half
            bod_x_1=patch_size_x_half-1
        else:
            bod_x_2=self._img_dim_x-patch_size_x_half
            bod_x_1=patch_size_x_half-2
            
        if patch_size_y%2==1:    
            bod_y_2=self._img_dim_y-patch_size_y_half
            bod_y_1=patch_size_y_half-1
        else:
            bod_y_2=self._img_dim_y-patch_size_y_half
            bod_y_1=patch_size_y_half-2
        
        three_d_index=self.one_d_index_to_3d_index(index)
        
        if three_d_index[1]>=bod_y_2 or three_d_index[1]<=bod_y_1 or three_d_index[2]>=bod_x_2 or three_d_index[2]<=bod_x_1:
            return 1
        else:
            return 0
        

    def next_batch(self, sample_num, patch_size_x,patch_size_y, input_img_pick, output_img_pick):
        #return the next sample_num examples from this data set
        #since each sample in the object is 3D, we need to specify which slices of the image are
        #used as input data and which are used as output data
        #the vector input_img_pick specifies the slice of the input image
        #the vector output_img_pick specifies the slice indexes of the output image
        #the input_data is sample_num by num of elements input_img_pick by patch_size_x by patch_size_y 
        #the input_data is sample_num by num of elements input_img_pick by 1 by 1 
        start=self._index_in_epoch
        self._index_in_epoch=start+sample_num
        if self._index_in_epoch>self._num_examples:
            self._epochs_completed+=1
            np.random.shuffle(self._perm)
            start=0;
            self._index_in_epoch=start+sample_num
            
        #in the network, the data have a format of (?,dim_x,dim_y,channel)
        #our output should better follow such format
        input_data=np.zeros((sample_num,patch_size_y,patch_size_x,len(input_img_pick)))
        output_data=np.zeros((sample_num,1,1,len(output_img_pick)))

        patch_size_x_half=patch_size_x//2;
        patch_size_y_half=patch_size_y//2;

        idx=0;
        while idx < sample_num:
            temp_idx=self._perm[start+idx]
            three_d_index=self.one_d_index_to_3d_index(temp_idx)
            #judge whether the idx reaches the boudaries of the image
            #if the boudaries are reached, then continue with the next idx
            #if not, output the patch
            while self.judge_whether_index_reach_boundary(temp_idx, patch_size_x, patch_size_y):
                temp_idx=(temp_idx+1)%self._num_examples
                three_d_index=self.one_d_index_to_3d_index(temp_idx)
            
            #these two variables judge how the patch is taken depending on whether x and y are even or odd
            even_odd_x = (patch_size_x+1)%2
            even_odd_y = (patch_size_y+1)%2

            temp_data=self._data[three_d_index[0],input_img_pick,\
                                 three_d_index[1]-patch_size_y_half+even_odd_y:three_d_index[1]+patch_size_y_half+1,\
                                 three_d_index[2]-patch_size_x_half+even_odd_x:three_d_index[2]+patch_size_x_half+1]
            temp_data=np.transpose(temp_data,(1,2,0))
            input_data[idx,:,:,:]=temp_data
            temp_data=self._data[three_d_index[0],output_img_pick,three_d_index[1],three_d_index[2]]
            output_data[idx,0,0,:]=temp_data
                
            idx=idx+1

        return input_data, output_data

    def next_batch_for_test(self, sample_num, patch_size_x,patch_size_y, input_img_pick, output_img_pick):
        start=self._index_in_epoch
        self._index_in_epoch=start+sample_num
        if self._index_in_epoch>self._num_examples:
            self._epochs_completed+=1
            np.random.shuffle(self._perm)
            start=0;
            self._index_in_epoch=start+sample_num

        input_data=np.zeros((sample_num,patch_size_y,patch_size_x,len(input_img_pick)))
        output_data=np.zeros((sample_num,1,1,len(output_img_pick)))

        patch_size_x_half=patch_size_x//2;
        patch_size_y_half=patch_size_y//2;

        idx=0;
        while idx < sample_num:
            temp_idx=self._perm[start+idx]
            three_d_index=self.one_d_index_to_3d_index(temp_idx)
            
            #judge whether the idx reaches the boudaries of the image
            if not self.judge_whether_index_reach_boundary(temp_idx, patch_size_x, patch_size_y):
                even_odd_x = (patch_size_x+1)%2
                even_odd_y = (patch_size_y+1)%2

                temp_data=self._data[three_d_index[0],input_img_pick,\
                                     three_d_index[1]-patch_size_y_half+even_odd_y:three_d_index[1]+patch_size_y_half+1,\
                                     three_d_index[2]-patch_size_x_half+even_odd_x:three_d_index[2]+patch_size_x_half+1]
                temp_data=np.transpose(temp_data,(1,2,0))
                input_data[idx,:,:,:]=temp_data
                temp_data=self._data[three_d_index[0],output_img_pick,three_d_index[1],three_d_index[2]]
                output_data[idx,0,0,:]=temp_data
                    
            idx=idx+1

        return input_data, output_data
    
    
    def next_batch_samesize(self, sample_num, patch_size_x,patch_size_y, input_img_pick, output_img_pick):
        #return the next sample_num examples from this data set
        #since each sample in the object is 3D, we need to specify which slices of the image are
        #used as input data and which are used as output data
        #the vector input_img_pick specifies the slice of the input image
        #the vector output_img_pick specifies the slice indexes of the output image
        #the input_data is sample_num by num of elements input_img_pick by patch_size_x by patch_size_y 
        #the input_data is sample_num by num of elements input_img_pick by patch_size_x by patch_size_y 
        start=self._index_in_epoch
        self._index_in_epoch=start+sample_num
        if self._index_in_epoch>self._num_examples:
            self._epochs_completed+=1
            np.random.shuffle(self._perm)
            start=0;
            self._index_in_epoch=start+sample_num

        input_data=np.zeros((sample_num,patch_size_y,patch_size_x,len(input_img_pick)))
        output_data=np.zeros((sample_num,patch_size_y,patch_size_x,len(output_img_pick)))

        patch_size_x_half=patch_size_x//2;
        patch_size_y_half=patch_size_y//2;

        idx=0;
        while idx < sample_num:
            temp_idx=self._perm[start+idx]
            three_d_index=self.one_d_index_to_3d_index(temp_idx)
            
            #judge whether the idx reaches the boudaries of the image
            while self.judge_whether_index_reach_boundary(temp_idx, patch_size_x, patch_size_y):
                temp_idx=(temp_idx+1)%self._num_examples
                three_d_index=self.one_d_index_to_3d_index(temp_idx)
                
            even_odd_x = (patch_size_x+1)%2
            even_odd_y = (patch_size_y+1)%2   

            temp=self._data[three_d_index[0],input_img_pick,\
                             three_d_index[1]-patch_size_y_half+even_odd_y:three_d_index[1]+patch_size_y_half+1,\
                             three_d_index[2]-patch_size_x_half+even_odd_x:three_d_index[2]+patch_size_x_half+1]
            input_data[idx,:,:,:]=np.transpose(temp,(1,2,0))
            temp=self._data[three_d_index[0],output_img_pick,\
                             three_d_index[1]-patch_size_y_half+even_odd_y:three_d_index[1]+patch_size_y_half+1,\
                             three_d_index[2]-patch_size_x_half+even_odd_x:three_d_index[2]+patch_size_x_half+1]
            output_data[idx,:,:,:]=np.transpose(temp,(1,2,0))

            
            idx=idx+1

        return input_data, output_data
    
    def next_batch_samesize_test(self, sample_num, patch_size_x,patch_size_y, input_img_pick, output_img_pick):
        #return the next sample_num examples from this data set
        #since each sample in the object is 3D, we need to specify which slices of the image are
        #used as input data and which are used as output data
        #the vector input_img_pick specifies the slice of the input image
        #the vector output_img_pick specifies the slice indexes of the output image
        #the input_data is sample_num by num of elements input_img_pick by patch_size_x by patch_size_y 
        #the input_data is sample_num by num of elements input_img_pick by patch_size_x by patch_size_y 
        start=self._index_in_epoch

        self._index_in_epoch=start+sample_num
        if self._index_in_epoch>self._num_examples:
            self._epochs_completed+=1
            start=0;
            self._index_in_epoch=start+sample_num

        input_data=np.zeros((sample_num,patch_size_y,patch_size_x,len(input_img_pick)))
        output_data=np.zeros((sample_num,patch_size_y,patch_size_x,len(output_img_pick)))

        patch_size_x_half=patch_size_x//2;
        patch_size_y_half=patch_size_y//2;

        idx=0;
        while idx < sample_num:
            temp_idx=self._perm[start+idx]
            three_d_index=self.one_d_index_to_3d_index(temp_idx)
            
            #judge whether the idx reaches the boudaries of the image
            if not self.judge_whether_index_reach_boundary(temp_idx, patch_size_x, patch_size_y):
                
                three_d_index=self.one_d_index_to_3d_index(temp_idx)
                temp_idx=(temp_idx+1)%self._num_examples
                
                even_odd_x = (patch_size_x+1)%2
                even_odd_y = (patch_size_y+1)%2   
    
                temp=self._data[three_d_index[0],input_img_pick,\
                                 three_d_index[1]-patch_size_y_half+even_odd_y:three_d_index[1]+patch_size_y_half+1,\
                                 three_d_index[2]-patch_size_x_half+even_odd_x:three_d_index[2]+patch_size_x_half+1]
                input_data[idx,:,:,:]=np.transpose(temp,(1,2,0))
                temp=self._data[three_d_index[0],output_img_pick,\
                                 three_d_index[1]-patch_size_y_half+even_odd_y:three_d_index[1]+patch_size_y_half+1,\
                                 three_d_index[2]-patch_size_x_half+even_odd_x:three_d_index[2]+patch_size_x_half+1]
                output_data[idx,:,:,:]=np.transpose(temp,(1,2,0))
                
            idx=idx+1

        return input_data, output_data