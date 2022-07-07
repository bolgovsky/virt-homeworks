# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

---

В данном файле приведены **только ответы** ! Т.е. можно искать по **Ответ:**

---


Бывает, что 
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  

---

1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   

**Ответ:** шутка ли или нет, но по `resource` и `data_source` находит боле 2000 результатов... и да - пробовал поиск и в IDE, и в Github.
Однако я нашел описание: 
```bash
type Provider struct {
...

	// ResourcesMap is the list of available resources that this provider
	// can manage, along with their Resource structure defining their
	// own schemas and CRUD operations.
	//
	// Provider automatically handles routing operations such as Apply,
	// Diff, etc. to the proper resource.
	ResourcesMap map[string]*Resource

	// DataSourcesMap is the collection of available data sources that
	// this provider implements, with a Resource instance defining
	// the schema and Read operation of each.
	//
	// Resource instances for data sources must have a Read function
	// and must *not* implement Create, Update or Delete.
	DataSourcesMap map[string]*Resource
	...
```
Таким образом искал далее `ResourcesMap`:  [ссылка на строку в коде на 
гитхабе - ResourcesMap](https://github.com/hashicorp/terraform-provider-aws/blob/721178399a76af98ab50c2e77ba21182a492151a/internal/provider/provider.go#L916)

и `DataSourcesMap`: [ссылка на строку в коде на 
гитхабе - DataSourcesMap](https://github.com/hashicorp/terraform-provider-aws/blob/87b2ab2a3c0b420f84a3942664205109dbcde609/internal/provider/provider.go#L425)

---

2. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.

**Ответ:** ConflictsWith: []string{"name_prefix"} . [ссылка на строку в коде на гитхабе](https://github.com/hashicorp/terraform-provider-aws/blob/721178399a76af98ab50c2e77ba21182a492151a/internal/service/sqs/queue.go#L87)
```bash
package sqs
...
var (
...
		"name": {
			Type:          schema.TypeString,
			Optional:      true,
			Computed:      true,
			ForceNew:      true,
			ConflictsWith: []string{"name_prefix"},
		},
		"name_prefix": {
			Type:          schema.TypeString,
			Optional:      true,
			Computed:      true,
			ForceNew:      true,
			ConflictsWith: []string{"name"},
		},
		...
		)
```

  * Какая максимальная длина имени? 
  * Какому регулярному выражению должно подчиняться имя?

**Ответ:** не понял как конкретно это искать в коде, но нашел несколько вариантов:
1. [Документация на ресурс aws_sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue#name_prefix) 
```bash 
name- (Необязательно) Имя очереди. Имена очередей должны состоять только из прописных и строчных букв ASCII, цифр, знаков подчеркивания и дефисов и должны содержать от 1 до 80 символов. 
Для очереди FIFO (первым поступил – первым обслужен) имя должно заканчиваться .fifoсуффиксом. Если его не указать, Terraform присвоит случайное уникальное имя. Конфликты сname_prefix
```

2. порыться в коде - в какой-то старой ветке нашел: 
```bash
func validateSQSQueueName(v interface{}, k string) (ws []string, errors []error) {
	value := v.(string)
	if len(value) > 80 {
		errors = append(errors, fmt.Errorf("%q cannot be longer than 80 characters", k))
	}

	if !regexp.MustCompile(`^[0-9A-Za-z-_]+(\.fifo)?$`).MatchString(value) {
		errors = append(errors, fmt.Errorf("only alphanumeric characters and hyphens allowed in %q", k))
	}
	return
}
```

В ветке ``main`` ссылок на проверку не нашел, только в функции `resourceQueueCustomizeDiff` есть :
```bash
var re *regexp.Regexp

		if fifoQueue {
			re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,75}\.fifo$`)
		} else {
			re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,80}$`)
		} 
```

--- 

## Задача 2. (Не обязательно) 
В рамках вебинара и презентации мы разобрали как создать свой собственный провайдер на примере кофемашины. 
Также вот официальная документация о создании провайдера: 
[https://learn.hashicorp.com/collections/terraform/providers](https://learn.hashicorp.com/collections/terraform/providers).

1. Проделайте все шаги создания провайдера.
2. В виде результата приложение ссылку на исходный код.
3. Попробуйте скомпилировать провайдер, если получится то приложите снимок экрана с командой и результатом компиляции.   

