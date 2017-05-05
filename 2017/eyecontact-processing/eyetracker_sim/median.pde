public static float[] quickSort(float[] data) {
  int lenD = data.length;
  float pivot = 0;
  int ind = lenD/2;
  int i, j = 0, k = 0;
  if (lenD<2) {
    return data;
  } else {
    float[] L = new float[lenD];
    float[] R = new float[lenD];
    float[] sorted = new float[lenD];
    pivot = data[ind];
    for (i=0;i<lenD;i++) {
      if (i!=ind) {
        if (data[i]<pivot) {
          L[j] = data[i];
          j++;
        }
        else {
          R[k] = data[i];
          k++;
        }
      }
    }
    float[] sortedL = new float[j];
    float[] sortedR = new float[k];
    arraycopy(L, 0, sortedL, 0, j);
    arraycopy(R, 0, sortedR, 0, k);
    sortedL = quickSort(sortedL);
    sortedR = quickSort(sortedR);
    arraycopy(sortedL, 0, sorted, 0, j);
    sorted[j] = pivot;
    arraycopy(sortedR, 0, sorted, j+1, k);
    return sorted;
  }
}

public static float median(float[] m) {
  // MUST BE SORTED
    int middle = m.length/2;
    if (m.length%2 == 1) {
        return m[middle];
    } else {
        return (m[middle-1] + m[middle]) / 2.0;
    }
}


public static PVector pvec_median(ArrayList<PVector> list) {

  float[] unsorted_x_list = new float[list.size()];
  float[] unsorted_y_list = new float[list.size()];
  float[] sorted_x_list = new float[list.size()];
  float[] sorted_y_list = new float[list.size()];

  int i = 0;
  for(PVector p : list) {
    unsorted_x_list[i] = p.x;
    unsorted_y_list[i] = p.y;
    i++;
  }

  sorted_x_list = quickSort(unsorted_x_list);
  sorted_y_list = quickSort(unsorted_y_list);


  return new PVector(median(sorted_x_list), median(sorted_y_list));
}
