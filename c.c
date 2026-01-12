#include <stdio.h>
int main() {
	while (1) {
		printf("A. Да\n");
		printf("B. Нет, я пидорас и капитолист\n");
		printf("C. Уже умер\n");
		char pol[10];
		printf("Готов умереть за родину? ");
		scanf("%s", pol);
		if (pol[0] == 'A' || pol[0] == 'a') {
		    printf("ГООООЙДА\n");
		    return 0;
		}
		else if (pol[0] == 'B' || pol[0] == 'b') {
		    printf("Ты хуесос, расист, антисимит, авторетарный, атнидемократ\n");
		    return 0;
		}
		else if (pol[0] == 'C' || pol[0] == 'c') {
			printf("Страна гордится тобой\n");
			return 0;
		}
		else {
			printf("ты что еблан, нормальную букву вставь\n");
		}
	}
}
