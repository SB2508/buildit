# Actual rules for building the library and the executables
.PRECIOUS: $(BUILD_DIR)/%.o 
.PRECIOUS: $(BUILD_DIR)/samples/%.o 

$(BUILD_DIR)/gen_headers/gen/compiler_headers.h:
	@mkdir -p $(@D)
	@echo "#pragma once" > $@
	@echo "#define GEN_TEMPLATE_NAME \"$(BASE_DIR)/scratch/code_XXXXXX\"" >> $@
	@echo "#define COMPILER_PATH \"$(CC)\"" >> $@
	@echo "#define CXX_COMPILER_PATH \"$(CXX)\"" >> $@

$(LIBRARY_OBJS): $(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp $(GEN_INCLUDES)
	@mkdir -p $(@D)
	$(CXXV) $(CFLAGS_INTERNAL) $(CFLAGS) $< -o $@ $(INCLUDE_FLAGS) -c -MMD -MP -MT $@ -MF $(@:.o=.td)
	@mv -f $(@:.o=.td) $(@:.o=.d)

$(BUILD_DIR)/samples/%.o: $(SAMPLES_DIR)/%.cpp $(GEN_INCLUDES)
	@mkdir -p $(@D)
	$(CXXV) $(CFLAGS_INTERNAL) $(CFLAGS) $< -o $@ $(INCLUDE_FLAGS) -c -MMD -MP -MT $@ -MF $(@:.o=.td)
	@mv -f $(@:.o=.td) $(@:.o=.d)
	
$(LIBRARY): $(LIBRARY_OBJS) $(DEPS_LIST)
	@mkdir -p $(@D)
	$(ARV) cr $(LIBRARY) $(LIBRARY_OBJS)

$(BUILD_DIR)/sample%: $(BUILD_DIR)/samples/sample%.o $(LIBRARY) $(DEPS_LIST)
	@mkdir -p $(@D)
	$(CXXLDV) -o $@ $< $(LINKER_FLAGS)


# Extra rules to simply compile the samples by name
$(SAMPLE_NAMES): sample%: $(BUILD_DIR)/sample%

.PHONY: executables
executables: $(SAMPLES)

.PHONY: lib
lib: $(LIBRARY)

-include $(LIBRARY_OBJS:.o=.d)
-include $(SAMPLE_OBJS:.o=.d)
