AUTO_CXX_SRC_FILES=
AUTO_SIMPLE_C_SRC_FILES=

NO_COLOR=\x1b[0m
MODE_COLOR=\x1b[31;01m
FILE_COLOR=\x1b[35;01m

Q = @

# Create rules to compile each .cpp file of a folder

define folder_compile

debug/$(1)/%.cpp.o: $(1)/%.cpp
	@mkdir -p debug/$(1)/
	@echo -e "$(MODE_COLOR)[debug]$(NO_COLOR) Compile $(FILE_COLOR)$(1)/$$*.cpp$(NO_COLOR)"
	$(Q)$(CXX) $(CXX_FLAGS) $(DEBUG_FLAGS) $(2) -MD -MF debug/$(1)/$$*.cpp.d -o debug/$(1)/$$*.cpp.o -c $(1)/$$*.cpp
	@ sed -i -e 's@^\(.*\)\.o:@\1.d \1.o:@' debug/$(1)/$$*.cpp.d

release/$(1)/%.cpp.o: $(1)/%.cpp
	@mkdir -p release/$(1)/
	@echo -e "$(MODE_COLOR)[release]$(NO_COLOR) Compile $(FILE_COLOR)$(1)/$$*.cpp$(NO_COLOR)"
	$(Q)$(CXX) $(CXX_FLAGS) $(RELEASE_FLAGS) $(2) -MD -MF release/$(1)/$$*.cpp.d -o release/$(1)/$$*.cpp.o -c $(1)/$$*.cpp
	@ sed -i -e 's@^\(.*\)\.o:@\1.d \1.o:@' release/$(1)/$$*.cpp.d

release_debug/$(1)/%.cpp.o: $(1)/%.cpp
	@mkdir -p release_debug/$(1)/
	@echo -e "$(MODE_COLOR)[release_debug]$(NO_COLOR) Compile $(FILE_COLOR)$(1)/$$*.cpp$(NO_COLOR)"
	$(Q)$(CXX) $(CXX_FLAGS) $(RELEASE_DEBUG_FLAGS) $(2) -MD -MF release_debug/$(1)/$$*.cpp.d -o release_debug/$(1)/$$*.cpp.o -c $(1)/$$*.cpp
	@ sed -i -e 's@^\(.*\)\.o:@\1.d \1.o:@' release_debug/$(1)/$$*.cpp.d

endef

# Create rules to compile each .c file of a folder (C files are compiled in C++ mode)

define simple_c_folder_compile

debug/$(1)/%.c.o: $(1)/%.c
	@ mkdir -p debug/$(1)/
	@echo -e "$(MODE_COLOR)[debug]$(NO_COLOR) Compile $(FILE_COLOR)$(1)/$$*.c$(NO_COLOR)"
	$(Q)$(CXX) $(CXX_FLAGS) $(DEBUG_FLAGS) $(2) -MD -MF debug/$(1)/$$*.c.d -o debug/$(1)/$$*.c.o -c $(1)/$$*.c
	@ sed -i -e 's@^\(.*\)\.o:@\1.d \1.o:@' debug/$(1)/$$*.c.d

release/$(1)/%.c.o: $(1)/%.c
	@ mkdir -p release/$(1)/
	@echo -e "$(MODE_COLOR)[release]$(NO_COLOR) Compile $(FILE_COLOR)$(1)/$$*.c$(NO_COLOR)"
	$(Q)$(CXX) $(CXX_FLAGS) $(RELEASE_FLAGS) $(2) -MD -MF release/$(1)/$$*.c.d -o release/$(1)/$$*.c.o -c $(1)/$$*.c
	@ sed -i -e 's@^\(.*\)\.o:@\1.d \1.o:@' release/$(1)/$$*.c.d

release_debug/$(1)/%.c.o: $(1)/%.c
	@ mkdir -p release_debug/$(1)/
	@echo -e "$(MODE_COLOR)[release_debug]$(NO_COLOR) Compile $(FILE_COLOR)$(1)/$$*.c$(NO_COLOR)"
	$(Q)$(CXX) $(CXX_FLAGS) $(RELEASE_DEBUG_FLAGS) $(2) -MD -MF release_debug/$(1)/$$*.c.d -o release_debug/$(1)/$$*.c.o -c $(1)/$$*.c
	@ sed -i -e 's@^\(.*\)\.o:@\1.d \1.o:@' release_debug/$(1)/$$*.c.d

endef

# Create rules to compile the src folder

define src_folder_compile

$(eval $(call folder_compile,src$(1),$(2)))

endef

# Create rules to compile the test folder

define test_folder_compile

$(eval $(call folder_compile,test$(1),$(2)))

endef

# Create rules to compile cpp files in the given folder and gather source files from it

define auto_folder_compile

$(eval $(call folder_compile,$(1),$(2)))

AUTO_SRC_FILES += $(wildcard $(1)/*.cpp)
AUTO_CXX_SRC_FILES += $(wildcard $(1)/*.cpp)

endef

# Create rules to compile C files in the given folder and gather source files from it

define auto_simple_c_folder_compile

$(eval $(call simple_c_folder_compile,$(1),$(2)))

AUTO_SRC_FILES += $(wildcard $(1)/*.c)
AUTO_SIMPLE_C_SRC_FILES += $(wildcard $(1)/*.c)

endef

# Create rules to link an executable with a set of files

define add_executable

debug/bin/$(1): $(addsuffix .o,$(addprefix debug/,$(2)))
	@mkdir -p debug/bin/
	@echo -e "$(MODE_COLOR)[debug]$(NO_COLOR) Link $(FILE_COLOR)$$@$(NO_COLOR)"
	$(Q)$(LD) $(DEBUG_FLAGS) -o $$@ $$+ $(LD_FLAGS) $(3)

release/bin/$(1): $(addsuffix .o,$(addprefix release/,$(2)))
	@mkdir -p release/bin/
	@echo -e "$(MODE_COLOR)[release]$(NO_COLOR) Link $(FILE_COLOR)$$@$(NO_COLOR)"
	$(Q)$(LD) $(RELEASE_FLAGS) -o $$@ $$+ $(LD_FLAGS) $(3)

release_debug/bin/$(1): $(addsuffix .o,$(addprefix release_debug/,$(2)))
	@mkdir -p release_debug/bin/
	@echo -e "$(MODE_COLOR)[release_debug]$(NO_COLOR) Link $(FILE_COLOR)$$@$(NO_COLOR)"
	$(Q)$(LD) $(RELEASE_DEBUG_FLAGS) -o $$@ $$+ $(LD_FLAGS) $(3)

endef

# Creates rules to create an executable with all the given files in the src folder

define add_src_executable

$(eval $(call add_executable,$(1),$(addprefix src/,$(2)),$(3)))

endef

# Creates rules to create an executable with all the given files in the test folder

define add_test_executable

$(eval $(call add_executable,$(1),$(addprefix test/,$(2)),$(3)))

endef

# Creates rules to create an executable with all the files of the src folder

define add_auto_src_executable

$(eval $(call add_executable,$(1),$(wildcard src/*.cpp)))

endef

# Creates rules to create an executable with all the files of the test folder

define add_auto_test_executable

$(eval $(call add_executable,$(1),$(wildcard test/*.cpp)))

endef

# Create an executable with all the files gather with auto_folder_compile

define auto_add_executable

$(eval $(call add_executable,$(1),$(AUTO_SRC_FILES)))
$(eval $(call add_executable_set,$(1),$(1)))

endef

# Create executable sets targets

define add_executable_set

release_$(1): $(addprefix release/bin/,$(2))
release_debug_$(1): $(addprefix release_debug/bin/,$(2))
debug_$(1): $(addprefix debug/bin/,$(2))
$(1): release_$(1)

endef

# Include D files

define auto_finalize

AUTO_DEBUG_D_FILES=$(AUTO_CXX_SRC_FILES:%.cpp=debug/%.cpp.d) $(AUTO_SIMPLE_C_SRC_FILES:%.c=debug/%.c.d)
AUTO_RELEASE_D_FILES=$(AUTO_CXX_SRC_FILES:%.cpp=release/%.cpp.d) $(AUTO_SIMPLE_C_SRC_FILES:%.c=release/%.c.d)
AUTO_RELEASE_DEBUG_D_FILES=$(AUTO_CXX_SRC_FILES:%.cpp=release_debug/%.cpp.d) $(AUTO_SIMPLE_C_SRC_FILES:%.c=release_debug/%.c.d)

endef

# Target to generate the compilation database for clang

.PHONY: compile_db

compile_commands.json:
	${MAKE} clean
	bear make debug

compile_db: compile_commands.json ;

# Clean target

.PHONY: base_clean

base_clean:
	rm -rf release/
	rm -rf release_debug/
	rm -rf debug/
