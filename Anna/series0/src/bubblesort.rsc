module bubblesort

import List;
import IO;

public list[int] sort2( list[int] numbers){
	int length = size(numbers);
	if (length > 0){
		for (int y <- [0 .. length-1]){
			if (numbers[y+1] < numbers[y]){
				<numbers[y],numbers[y+1]> = <numbers[y+1],numbers[y]>;
				return sort2(numbers);
			}
		}
	}
	return numbers;
}

bool isSorted(list[int] lst) = !any(int i <- index(lst), int j <- index(lst), (i < j) && (lst[i] > lst[j]));